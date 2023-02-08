import 'dart:async';

import 'package:flutter/material.dart';
import 'package:life_log/settings/viewmodel.dart';
import 'package:mypack/utils/time.dart';

import '../log/model.dart';
import '../settings/model.dart';

class LoginModel extends SettingsModel {
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
                "type the password to login${pass == 'guest' ? ", 'guest' for now" : " $pass"}",
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

  @override
  void getInput() async {
    // check login
    if (controller.text == pass) {
      settingsApi.setLoggedIn();
    }
    // save log
    appendLog(controller.text);
    // parse
    var text = controller.text;
    controller.clear();

    if (!text.contains(", ")) return;
    var name = text.split(", ").first;
    var msg = text.split(", ").last;
    // login command
    if (name == ISettingsApi.passName && msg == pass) {
      appendLog("Welcome back $user!");
      Future.delayed(
          const Duration(seconds: 2), () => settingsApi.setLoggedIn());
    }
    //color command
    else if (name == ISettingsApi.colorName) {
      var color = int.tryParse(msg);
      if (color != null && color >= 0 && color < totColors) {
        setMainColor(color: SettingsModel.colors[color]);
      } else {
        appendLog("Invalid color");
      }
    }
    // user command
    else if (name == ISettingsApi.userName) {
      appendLog("I find $msg to be perfect!");
      settingsApi.setSetting(ISettingsApi.userName, msg);
    }
  }

  @override
  void logOut() {
    appendLog("Goodbye $user!");
    super.logOut();
  }
}
