import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mypack/core/enums/viewstate.dart';
import 'package:mypack/core/viewmodels/base_viewmodel.dart';
import 'package:mypack/locator.dart';
import 'package:mypack/utils/time.dart';
import '../login/viewmodel.dart';
import 'model.dart';
import 'sqfl.dart';

class SettingsModel extends BaseModel {
  static const MaterialColor defaultColor = Colors.yellow;
  static const int defaultColorIndex = 3;
  static final StreamController<Color> _mainColorStreamController =
      StreamController.broadcast();
  static const String settingMsg = "setting";

  static Stream<Color> get mainColorStream => _mainColorStreamController.stream;

  // settings
  @protected
  late final SettingsSqflApi settingApi;
  late Stream<List<SettingsEntry>> settingsEntryStream;
  late List<SettingsEntry> _settings;
  late int _colorIndex;
  late int _totalEntries;
  late int _trashedEntries;
  late String _user;
  late String _pass;
  late bool _logged;
  final controller = TextEditingController();

  Color get mainColor => colors[colorIndex];
  int get colorIndex => _colorIndex;
  int get totalEntries => _totalEntries;
  int get trashedEntries => _trashedEntries;
  String get user => _user;
  String get pass => _pass;
  bool get logged => _logged;

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

  void listener(List<SettingsEntry> settings) async {
    _settings = settings;
    _colorIndex =
        getColorIndexIfValid(ISettingsApi.colorName) ?? defaultColorIndex;
    _totalEntries = getIntIfValid(ISettingsApi.totalName) ?? 0;
    _trashedEntries = getIntIfValid(ISettingsApi.trashName) ?? 0;
    _user = (_settings.where((e) => e.name == ISettingsApi.userName).isNotEmpty)
        ? _settings.where((e) => e.name == ISettingsApi.userName).first.msg
        : LoginModel.defaultUser;
    _pass = _settings.where((e) => e.name == ISettingsApi.passName).isNotEmpty
        ? _settings.where((e) => e.name == ISettingsApi.passName).first.msg
        : LoginModel.defaultPass;
    _logged = _settings
            .where((e) => e.name == ISettingsApi.loggedName)
            .isNotEmpty
        ? _settings.where((e) => e.name == ISettingsApi.loggedName).first.msg !=
            "0"
        : false;
    notifyListeners();
  }

  int? getIntIfValid(String name, {List<SettingsEntry>? results}) {
    var val = int.tryParse((results ?? _settings)
        .firstWhere((e) => e.name == ISettingsApi.colorName,
            orElse: () => SettingsEntry(
                id: 0,
                lastModified: now.millisecondsSinceEpoch,
                exportId: null,
                name: ISettingsApi.colorName,
                msg: "$defaultColorIndex"))
        .msg);
    return val;
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
  bool findSomeColors(List<SettingsEntry> results) =>
      results.where((e) => e.msg.startsWith(ISettingsApi.colorName)).isNotEmpty;

  int? getColorIndexIfValid(String name, {List<SettingsEntry>? results}) {
    var val = getIntIfValid(ISettingsApi.colorName, results: results);
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

  getColor(int? i) =>
      colors[i != null && i >= 0 && i < totColors ? i : colorIndex];

  String niceColor(int i) => nice(colors[i].value);

  getInput() {
    var text = controller.text;
    if (!text.contains(", ")) return;
    var name = text.split(", ").first;
    var msg = text.split(", ").last;
    if (name == ISettingsApi.colorName) {
      var color = getColor(int.tryParse(msg));
      setMainColor(color: color);
    } else if (name == ISettingsApi.userName) {
      settingApi.setSetting(ISettingsApi.userName, msg);
    } else if (name == ISettingsApi.passName) {
      settingApi.setSetting(ISettingsApi.passName, msg);
    } else if (name == ISettingsApi.totalName) {
    } else if (name == ISettingsApi.trashName) {
    } else {
      settingApi.setSetting(name, msg);
    }
    controller.clear();
  }
}
