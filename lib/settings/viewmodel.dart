import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mypack/core/enums/viewstate.dart';
import 'package:mypack/core/viewmodels/base_viewmodel.dart';
import 'package:mypack/locator.dart';
import 'model.dart';
import 'sqfl.dart';

class SettingsModel extends BaseModel {
  static const MaterialColor defaultColor = Colors.yellow;
  static const int defaultColorIndex = 3;
  @protected
  late final SettingsSqflApi settingApi;
  late Stream<List<SettingsEntry>> settingsEntryStream;

  late List<SettingsEntry> _settings;
  static final StreamController<Color> _mainColorStreamController =
      StreamController.broadcast();

  static Stream<Color> get mainColorStream => _mainColorStreamController.stream;
  Color get mainColor => colors[colorIndex];
  get colorIndex =>
      _settings.where((e) => e.name == ISettingsApi.colorName).first.msg;
  get totalEntries =>
      _settings.where((e) => e.name == ISettingsApi.totalName).first.msg;
  get trashedEntries =>
      _settings.where((e) => e.name == ISettingsApi.trashName).first.msg;
  get user => _settings.where((e) => e.name == ISettingsApi.userName).first.msg;
  get pass => _settings.where((e) => e.name == ISettingsApi.passName).first.msg;

  get controllerScroll => ScrollController();
  // load
  @override
  Future loadModel() async {
    setState(ViewState.busy);

    await locator.isReady<SettingsSqflApi>();
    settingApi = locator<SettingsSqflApi>();

    settingsEntryStream = settingApi.getSettingsEntriesStream();
    settingsEntryStream.listen(listener);
    setState(ViewState.idle);
  }

  static List<MaterialColor> get colors => [
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

  int get totColors => colors.length;

  void listener(List<SettingsEntry> settings) async {
    _settings = settings;

    notifyListeners();
  }

  bool findSomeColors(List<SettingsEntry> results) =>
      results.where((e) => e.msg.startsWith(ISettingsApi.colorName)).isNotEmpty;

  int? lastIfValid(List<SettingsEntry> results) {
    var val = int.tryParse(results
        .lastWhere((e) => e.msg.startsWith(ISettingsApi.colorName))
        .msg
        .substring(ISettingsApi.colorName.length));
    if (val != null && val >= 0 && val < colors.length) return val;
    return null;
  }

  Future setMainColor({MaterialColor? color}) async {
    _mainColorStreamController
        .add(colors[colors.indexOf(color ?? defaultColor)]);
    return settingApi.setSetting(
        ISettingsApi.colorName, "${colors.indexOf(color ?? defaultColor)}");
  }

  String nice(int colorValue) {
    if (colorValue == Colors.yellow.value) return "yellow";
    if (colorValue == Colors.red.value) return "red";
    if (colorValue == Colors.green.value) return "green";
    if (colorValue == Colors.blue.value) return "blue";
    if (colorValue == Colors.purple.value) return "purple";
    if (colorValue == Colors.orange.value) return "orange";
    if (colorValue == Colors.pink.value) return "pink";
    if (colorValue == Colors.teal.value) return "teal";
    if (colorValue == Colors.cyan.value) return "cyan";
    if (colorValue == Colors.lime.value) return "lime";
    if (colorValue == Colors.indigo.value) return "indigo";
    if (colorValue == Colors.brown.value) return "brown";
    if (colorValue == Colors.grey.value) return "grey";
    return "yellow";
  }

  getColor(int? i) => colors[i ?? colorIndex];

  String niceColor(int i) => nice(colors[i].value);
}
