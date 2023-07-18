import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/frontend.dart';
import 'model.dart';
import 'sqfl.dart';

class SettingsModel extends IScrollableModel<NoModelArgs> {
  static const MaterialColor defaultColor = Colors.yellow;
  static const int defaultColorIndex = 3;
  static final StreamController<Color> _mainColorStreamController =
      StreamController.broadcast();
  static const String settingsMsg = "settings";

  bool hideMode = true;

  static Stream<Color> get mainColorStream => _mainColorStreamController.stream;

  // settings
  @protected
  late final SettingsSqflApi settingsApi;
  @protected
  late Stream<List<SettingsEntry>> settingsEntryStream;
  @protected
  late List<SettingsEntry> settings;

  late int colorIndex;
  late int totalEntries;
  late int trashedEntries;
  late String user;
  late String pass;
  late bool logged;

  final controller = TextEditingController();

  Color get mainColor => colors[colorIndex];

  // load
  @override
  Future init({dynamic args}) async {
    setState(ViewState.busy);

    await locator.isReady<SettingsSqflApi>();
    settingsApi = locator<SettingsSqflApi>();

    settingsEntryStream = settingsApi.getSettingsEntriesStream();
    settingsEntryStream.listen(listener);
    setState(ViewState.idle);
  }

  void listener(List<SettingsEntry> s) async {
    settings = s;
    colorIndex =
        getColorIndexIfValid(ISettingsApi.colorName) ?? defaultColorIndex;
    totalEntries = getIntIfValid(ISettingsApi.totalName) ?? 0;
    trashedEntries = getIntIfValid(ISettingsApi.trashName) ?? 0;
    user = (settings.where((e) => e.name == ISettingsApi.userName).isNotEmpty)
        ? settings.where((e) => e.name == ISettingsApi.userName).first.msg
        : "";
    pass = settings.where((e) => e.name == ISettingsApi.passName).isNotEmpty
        ? settings.where((e) => e.name == ISettingsApi.passName).first.msg
        : "";
    logged =
        settings.where((e) => e.name == ISettingsApi.loggedName).isNotEmpty &&
                settings
                        .where((e) => e.name == ISettingsApi.loggedName)
                        .first
                        .msg ==
                    "1"
            ? true
            : false;
    notifyListeners();
  }

  int? getIntIfValid(String name, {List<SettingsEntry>? results}) {
    var val = int.tryParse((results ?? settings)
        .firstWhere((e) => e.name == ISettingsApi.colorName,
            orElse: () => SettingsEntry(
                id: 0,
                lastModified: DateTime.now().millisecondsSinceEpoch,
                exportId: null,
                name: ISettingsApi.colorName,
                msg: "$defaultColorIndex"))
        .msg);
    return val;
  }

  // colors
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
    return settingsApi.setSetting(
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

  /// user input
  getInput() {
    var text = controller.text;
    if (!text.contains(", ")) return;
    var name = text.split(", ").first;
    var msg = text.split(", ").last;
    // color command
    if (name == ISettingsApi.colorName) {
      setMainColor(color: getColor(int.tryParse(msg)));
    }
    // user command
    else if (name == ISettingsApi.userName) {
      settingsApi.setSetting(ISettingsApi.userName, msg);
    }
    // pass command
    else if (name == ISettingsApi.passName) {
      settingsApi.setSetting(ISettingsApi.passName, msg);
    }
    // uneditables
    else if (name == ISettingsApi.totalName) {
    } else if (name == ISettingsApi.trashName) {
    } else if (name == ISettingsApi.loggedName) {
    }
    // other
    else {
      settingsApi.setSetting(name, msg);
    }
    controller.clear();
  }

  /// logout
  void logOut() {
    settingsApi.setLoggedOut();
  }

  void toggleHideMode() {
    hideMode = !hideMode;
    notifyListeners();
  }
}
