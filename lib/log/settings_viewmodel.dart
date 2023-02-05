import 'package:flutter/material.dart';
import 'package:life_log/log/viewmodel.dart';
import 'model.dart';

class SettingsModel extends LogModel {
  // late final LogSqflApi _api;
  static const Color defaultColor = Colors.yellow;
  Color _mainColor = defaultColor;
  Iterable<int> _colorIds = [];
  late int _trashedEntries;
  late int _totalEntries;

  Color get mainColor => _mainColor;
  get totalEntries => _totalEntries;
  get trashedEntries => _trashedEntries;

  List<MaterialColor> get colors => [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
        Colors.pink,
        Colors.teal,
        Colors.cyan,
        Colors.lime,
        Colors.indigo,
        Colors.brown,
        Colors.grey
      ];

  @override
  void listener(List<LogEntry> logs) {
    _totalEntries = logs.length;
    _trashedEntries =
        logs.where((e) => e.msg.startsWith(ILogApi.delPrefix)).length;
    if (findSomeColors(logs) && lastIfValid(logs) != null) {
      _mainColor = Color(lastIfValid(logs)!);
      _colorIds =
          logs.where((e) => e.msg.startsWith("color, ")).map((e) => e.id);
    } else {
      setMainColor(color: Colors.yellow);
    }
    notifyListeners();
  }

  bool findSomeColors(List<LogEntry> results) =>
      results.where((e) => e.msg.startsWith("color, ")).isNotEmpty;

  int? lastIfValid(List<LogEntry> results) => int.tryParse(results
      .lastWhere((e) => e.msg.startsWith("color, "))
      .msg
      .substring("color, ".length));

  Future setMainColor({MaterialColor? color}) async {
    for (final id in _colorIds) {
      await api.deleteLogEntry(id);
    }
    _mainColor = color ?? defaultColor;
    return api
        .addLogEntry(LogFields("color, ${color?.value ?? defaultColor.value}"));
  }
}
