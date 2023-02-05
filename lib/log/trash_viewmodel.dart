import 'package:flutter/material.dart';
import 'package:mypack/core/enums/viewstate.dart';
import 'package:mypack/core/viewmodels/base_viewmodel.dart';
import 'package:mypack/locator.dart';
import 'package:mypack/utils/time.dart';

import 'sqfl.dart';
import 'model.dart';

class LogTrashModel extends BaseModel {
  late final LogSqflApi _api;
  // variables
  TextEditingController controller = TextEditingController();
  bool _searching = false;
  get searching => _searching;
  List<LogEntry> _entries = [];
  String query = "";
  List<LogEntry> get entries => _entries
      .where((e) => e.msg.contains(query))
      .where((e) => e.msg.startsWith(ILogApi.delPrefix))
      .toList();

  ScrollController controllerScroll = ScrollController();

  // load
  @override
  void loadModel() async {
    setState(ViewState.busy);

    await locator.isReady<LogSqflApi>();
    _api = locator<LogSqflApi>();

    // init variables
    _entries = await _api.getLogEntries();
    scrollDown();
    setState(ViewState.idle);
  }

  void scrollDown() async => Future.delayed(
      const Duration(milliseconds: 50),
      () => controllerScroll.animateTo(
            controllerScroll.position.maxScrollExtent,
            duration: Duration(
              milliseconds: (controllerScroll.position.maxScrollExtent -
                      controllerScroll.offset) ~/
                  5,
            ),
            curve: Curves.easeInOut,
          ));

  void scrollUp() async => Future.delayed(
      const Duration(milliseconds: 50),
      () => controllerScroll.animateTo(
            0,
            duration: Duration(
              milliseconds: controllerScroll.offset ~/ 5,
            ),
            curve: Curves.easeInOut,
          ));

  Future saveLog() async {
    await _api
        .addLogEntry(LogFields(controller.text))
        .then((value) => _entries.add(LogEntry(
              LogFields(controller.text),
              value,
              null,
              now.millisecondsSinceEpoch,
            )));
    controller.clear();
    search();
    scrollDown();
    notifyListeners();
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

  Future deleteLog(int id) => _api
      .deleteLogEntry(id)
      .then((value) => _entries.removeWhere((element) => element.id == id))
      .then((value) => notifyListeners());

  Future restoreLog(int id) => _api
      .restoreTrashed(id)
      .then((value) => _entries.where((element) => element.id == id))
      .then((e) => e.first)
      .then((val) => val.msg = val.msg.substring(ILogApi.delPrefix.length))
      .then((value) => notifyListeners());
}
