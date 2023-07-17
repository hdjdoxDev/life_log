import 'package:flutter/material.dart';
import '../login/viewmodel.dart';
import '../settings/sqfl.dart';
import 'package:frontend/frontend.dart';

import 'sqfl.dart';
import 'model.dart';

class LogModel extends IScrollableModel<NoModelArgs> {
  static const List<String> backMsgs = [
    "back",
    "main",
    "home",
    "menu",
    "exit",
  ];

  @protected
  late final LogSqflApi api;
  @protected
  late Stream<List<LogEntry>> logEntryStream;

  // variables
  TextEditingController controller = TextEditingController();
  bool _searching = false;
  get searching => _searching;
  List<LogEntry> entries = [];
  String query = "";

  List<LogEntry> get results => entries
      .where((e) => e.msg.contains(query))
      .where((e) => !e.msg.startsWith(ILogApi.delPrefix))
      .toList();

  // load
  @override
  Future init({dynamic args}) async {
    setState(ViewState.busy);

    await locator.isReady<LogSqflApi>();
    api = locator<LogSqflApi>();

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
    if (LoginModel.logOutMsgs.contains(controller.text)) {
      await locator<SettingsSqflApi>().setLoggedOut();
      return 0;
    }
    var ret = await api.addLogEntry(LogFields(controller.text));
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
}
