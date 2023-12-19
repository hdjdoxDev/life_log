import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/frontend.dart';
import 'package:utils/time.dart';

import '../data/model.dart';
import '../data/sqfl.dart';

class LogModel extends IScrollableModel<NoModelArgs> {
  // api to log storage
  @protected
  late final ILogApi api;

  // stream with updated log entries
  @protected
  late Stream<List<LogEntry>> logEntryStream;

  // variables
  // textfield controller
  TextEditingController controller = TextEditingController();
  // textfield focus node
  FocusNode focusNode = FocusNode();

  // when searching, the textfield updates the query of search
  bool _searchingMode = false;
  bool get searchingMode => _searchingMode;

  // selected category for view and new logs
  LogCategory _categorySelection = LogCategory.all;
  LogCategory get categorySelection => _categorySelection;

  // selected log entry for editing category
  int? _logSelection;
  int? get logSelection => _logSelection;

  // last text in textfield before clearing
  String lastText = "";

  // last logs retrieved from api
  List<LogEntry> entries = [];

  // query to filter logs
  String query = "";

  // logs to show in view
  List<LogEntry> get results => entries.where((e) => queryFilter(e)).toList();

  // condition to filter logs
  bool queryFilter(LogEntry e) =>
      // if message or date contains query
      (e.msg.contains(query) || dateTimeString(e.time).contains(query)) &&
      // and if message is not a deleted message
      !e.msg.startsWith(ILogApi.delPrefix) &&
      // and if category is selected or all are
      (categorySelection == LogCategory.all || e.category == categorySelection);

  // load
  @override
  Future init({dynamic args}) async {
    setState(ViewState.busy);

    // init api
    await locator.isReady<ILogApi>();
    api = locator<ILogApi>();

    // init log stream
    logEntryStream = api.getLogEntriesStream();
    logEntryStream.listen(streamListener);

    // listen to enter key
    RawKeyboard.instance.addListener(enterKeyboardListener);

    setState(ViewState.idle);
  }

  // listener for log stream
  void streamListener(List<LogEntry> logs) {
    entries = logs..sort((a, b) => a.time.compareTo(b.time));
    goToBottom(delay: 100);
    notifyListeners();
  }

  // listener for enter key
  void enterKeyboardListener(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      handleSave();
    }
  }

  // save new entry, unfocus when empty
  Future<int> handleSave() async {
    if (controller.text.isEmpty) {
      focusNode.unfocus();
      return 0;
    } else {
      var ret = await api
          .addLogEntry(LogFields(controller.text, category: categorySelection));
      controller.text = query;
      query = "";
      return ret;
    }
  }

  // switch for searching mode
  void handleSearch() {
    _searchingMode = !_searchingMode;
    if (_searchingMode) {
      searchListener();
      controller.addListener(searchListener);
    } else {
      controller.removeListener(searchListener);
    }
    goToBottom();
    notifyListeners();
  }

  // listener to controller updates when searching mode is on
  void searchListener() {
    query = controller.text;
    goToBottom();
    notifyListeners();
  }

  // move log entry to trash
  Future trashLog(int id) => api.moveToTrash(id);

  // copy log entry message to textfield
  void handleLogSwipe(String msg) => controller
    ..text = msg
    ..selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));

  // change category selection or udpate log category when selected
  void handleCategoryPick(LogCategory c) {
    if (logSelection == null) {
      _categorySelection = c;
    } else {
      api.editCategory(logSelection!, c);
      _logSelection = null;
    }
    goToBottom();
    notifyListeners();
  }

  // select log entry to edit category
  void handleLogLongPress(int id) {
    _logSelection = id;
    notifyListeners();
  }

  // clear textfield or restore when empty
  void handleSaveLongPress() {
    if (controller.text.isEmpty) {
      controller.text = lastText;
    } else {
      lastText = controller.text;
      controller.clear();
    }
  }
}
