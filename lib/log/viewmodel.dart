import 'package:flutter/material.dart';
import 'package:frontend/frontend.dart';

import '../data/model.dart';
import '../data/sqfl.dart';

class LogModel extends IScrollableModel<NoModelArgs> {
  @protected
  late final ILogApi api;
  @protected
  late Stream<List<LogEntry>> logEntryStream;

  // variables
  TextEditingController controller = TextEditingController();
  bool _searching = false;
  bool get searching => _searching;
  LogCategory _category = LogCategory.all;
  LogCategory get category => _category;
  int? _categoryIndex;
  int? get categoryIndex => _categoryIndex;

  List<LogEntry> entries = [];
  String query = "";

  List<LogEntry> get results => entries.where((e) => queryFilter(e)).toList();
  bool queryFilter(LogEntry e) =>
      e.msg.contains(query) &&
      !e.msg.startsWith(ILogApi.delPrefix) &&
      (category == LogCategory.all || e.category == category);
  // load
  @override
  Future init({dynamic args}) async {
    setState(ViewState.busy);

    await locator.isReady<ILogApi>();
    api = locator<ILogApi>();

    logEntryStream = api.getLogEntriesStream();
    logEntryStream.listen(listener);

    setState(ViewState.idle);
  }

  void listener(List<LogEntry> logs) {
    entries = logs;

    goToBottom(delay: 100);
    notifyListeners();
  }

  Future<int> saveLog() async {
    var ret =
        await api.addLogEntry(LogFields(controller.text, category: category));
    controller.clear();
    return ret;
  }

  void toggleSearch() {
    _searching = !_searching;
    if (_searching) {
      search();
      controller.addListener(search);
    } else {
      controller.removeListener(search);
    }
    goToBottom();
    notifyListeners();
  }

  void search() {
    query = controller.text;
    goToBottom();
    notifyListeners();
  }

  Future trashLog(int id) => api.moveToTrash(id);

  void copyLog(String msg) => controller
    ..text = msg
    ..selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));

  void setCategory(c) {
    if (categoryIndex == null) {
      _category = c;
    } else {
      api.editCategory(categoryIndex!, c);
      _categoryIndex = null;
    }
    goToBottom();
    notifyListeners();
  }

  void editCategory(int id) {
    _categoryIndex = id;
    notifyListeners();
  }
}
