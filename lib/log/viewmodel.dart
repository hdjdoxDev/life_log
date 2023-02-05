import 'package:flutter/material.dart';
import 'package:mypack/core/enums/viewstate.dart';
import 'package:mypack/core/viewmodels/base_viewmodel.dart';
import 'package:mypack/locator.dart';

import 'sqfl.dart';
import 'model.dart';

class LogModel extends BaseModel {
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

  ScrollController controllerScroll = ScrollController();

  // load
  @override
  Future loadModel() async {
    setState(ViewState.busy);

    await locator.isReady<LogSqflApi>();
    api = locator<LogSqflApi>();

    logEntryStream = api.getLogEntriesStream();
    logEntryStream.listen(listener);
    setState(ViewState.idle);
  }

  void listener(List<LogEntry> logs) {
    entries = logs;
    goToBottom();
    notifyListeners();
  }

  // Future<List<LogEntry>> loadEntries() async =>
  //     entries = await api.getLogEntries();
  
  void goToBottom({int delay = 50, int duration = 500, int threshold = 150}) =>
      controllerScroll.position.maxScrollExtent - controllerScroll.offset >
              threshold
          ? scrollDown(mill: duration, delay: delay)
          : moveDown(delay: delay);
  void moveDown({int delay = 50}) => Future.delayed(
      Duration(milliseconds: delay),
      () => controllerScroll.jumpTo(controllerScroll.position.maxScrollExtent));

  void scrollDown({int mill = 500, int delay = 50}) async => Future.delayed(
      Duration(milliseconds: delay),
      () => controllerScroll.animateTo(
            controllerScroll.position.maxScrollExtent,
            duration: Duration(
              milliseconds: mill,
            ),
            curve: Curves.decelerate,
          ));

  void scrollUp() async => Future.delayed(
      const Duration(milliseconds: 50),
      () => controllerScroll.animateTo(
            0,
            duration: const Duration(
              milliseconds: 500,
            ),
            curve: Curves.easeInOut,
          ));

  Future<int> saveLog() async {
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
    notifyListeners();
  }

  void search() {
    query = controller.text;
    notifyListeners();
  }

  Future trashLog(int id) => api.setDeleted(id);

  void copyLog(String msg) => controller.text = msg;
}
