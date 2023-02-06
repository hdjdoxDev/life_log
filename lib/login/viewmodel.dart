import 'dart:async';

import 'package:flutter/material.dart';
import 'package:life_log/model.dart';
import 'package:mypack/core/enums/viewstate.dart';
import 'package:mypack/locator.dart';
import 'package:mypack/utils/time.dart';

import '../log/model.dart';
import '../settings/model.dart';
import '../settings/sqfl.dart';

class LoginModel extends IScrollableModel {
  // static
  static const MaterialColor defaultColor = Colors.yellow;
  static const int defaultColorIndex = 3;
  static const String defaultPass = "guest";
  static const String defaultUser = "guest";
  static const List<String> logOutMsgs = [
    "bye",
    "see you",
    "goodbye",
    "see ya",
    "log out",
    "logout",
  ];

  static final StreamController<Color> _mainColorStreamController =
      StreamController.broadcast();

  static Stream<Color> get mainColorStream => _mainColorStreamController.stream;

  // logs
  TextEditingController controller = TextEditingController();
  List<LogEntry> get _logs => [
        LogEntry(
            msg: "hi, welcome to LifeLog!",
            id: 1,
            lastModified: now.millisecondsSinceEpoch),
        LogEntry(
            msg: "'user, the_user' will change how I'll call you, dear $user.",
            id: 2,
            lastModified: now.millisecondsSinceEpoch),
        LogEntry(
            msg: "with 'color, 0-11' to change the color of the app",
            id: 3,
            lastModified: now.millisecondsSinceEpoch),
        LogEntry(
            msg:
                "type the password to login${pass == 'guest' ? ", 'guest' for now" : ''}",
            id: 4,
            lastModified: now.millisecondsSinceEpoch),
        LogEntry(
            msg: "pass, ", id: 5, lastModified: now.millisecondsSinceEpoch),
        LogEntry(
            msg: "swipe on the previous message to copy the text",
            id: 6,
            lastModified: now.millisecondsSinceEpoch)
      ];
  final List<LogEntry> _tempLogs = [];
  List<LogEntry> get logs => [..._logs, ..._tempLogs];

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

  Color get mainColor => colors[colorIndex];
  get colorIndex => _colorIndex;
  get totalEntries => _totalEntries;
  get trashedEntries => _trashedEntries;
  get user => _user;
  get pass => _pass;

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

  void listener(List<SettingsEntry> settings) {
    _settings = settings;
    _colorIndex =
        getColorIndexIfValid(ISettingsApi.colorName) ?? defaultColorIndex;
    _totalEntries = getIntIfValid(ISettingsApi.totalName) ?? 0;
    _trashedEntries = getIntIfValid(ISettingsApi.trashName) ?? 0;
    _user = (_settings.where((e) => e.name == ISettingsApi.userName).isNotEmpty)
        ? _settings.where((e) => e.name == ISettingsApi.userName).first.msg
        : defaultUser;
    _pass = _settings.where((e) => e.name == ISettingsApi.passName).isNotEmpty
        ? _settings.where((e) => e.name == ISettingsApi.passName).first.msg
        : defaultPass;

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

  static int get totColors => colors.length;

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

  getColor(int? i) => colors[i ?? colorIndex];

  String niceColor(int i) => nice(colors[i].value);

  void copyLog(String msg) => controller
    ..text = msg
    ..selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));

  void appendLog(String msg) {
    _tempLogs.add(LogEntry(
        msg: msg,
        id: _logs.length + 1,
        lastModified: now.millisecondsSinceEpoch));
    notifyListeners();
    goToBottom();
  }

  void getInput() async {
    if (controller.text == pass) {
      settingApi.setLoggedIn();
    }
    appendLog(controller.text);
    if (!controller.text.contains(", ")) return;

    var words = controller.text.split(", ");
    var name = words[0];
    var msg = words[1];
    if (name == ISettingsApi.passName && msg == pass) {
      appendLog("Welcome back $user!");
      Future.delayed(
          const Duration(seconds: 2), () => settingApi.setLoggedIn());
    } else if (name == ISettingsApi.colorName) {
      var color = int.tryParse(msg);
      if (color != null && color >= 0 && color < colors.length) {
        setMainColor(color: colors[color]);
      } else {
        appendLog("Invalid color");
      }
    } else if (name == ISettingsApi.userName) {
      appendLog("I find $msg to be perfect!");
      settingApi.setSetting(ISettingsApi.userName, msg);
    }
    controller.clear();
  }

  void logOut() {
    settingApi.setLoggedOut();
    appendLog("Goodbye $user!");
  }
}
