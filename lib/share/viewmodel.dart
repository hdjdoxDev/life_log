import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/frontend.dart';
import '../data/model.dart';
import '../data/sqfl.dart';

enum ComState { init, sync, done }

const commaSeparator = ";";
const msgSeparator = "\n";
const pipeSeparator = "|";

class ShareModel extends IScrollableModel<NoModelArgs> {
  Socket? socket;
  late final ILogApi api;
  final TextEditingController ipController = TextEditingController()
    ..text = "192.168.1.77";
  ComState comState = ComState.init;
  String connection = 'ready';
  static const int port = 4646;

  bool connected = false;

  int totNewEntries = 0;

  String residual = "";

  // load
  @override
  void init({args = const NoModelArgs()}) async {
    setState(ViewState.busy);
    await locator.isReady<ILogApi>();
    api = locator<ILogApi>();
    setState(ViewState.idle);
  }

  void sendMessage(String msg) {
    socket!.write("$msg$msgSeparator");
  }

  void startSink() async {
    comState = ComState.sync;

    socket = await Socket.connect(ipController.text, port);
    socket!.encoding = utf8;

    socket!.listen(onData);

    sendMessage("SYNC");
    sendMessage("HEAD${LogEntry.csvHeaderContent}");
    sendMessage(await getSyncInfo());
    sendMessage("DONE");
  }

  void onData(Uint8List data) async {
    var dataString = utf8.decode(data);
    var lines = dataString.split(msgSeparator);
    lines[0] = residual + lines[0];
    residual = lines.removeLast();
    for (var line in lines) {
      handleMessage(line);
    }
  }

  void handleMessage(String line) {
    if (line.isEmpty) {
      return;
    }
    var comm = line.substring(0, 4);
    var args = line.substring(4);

    switch (comm) {
      case "ASKE":
        if (comState == ComState.sync) {
          sendSync(args);
        }
        break;
      case "UPDT":
        if (comState == ComState.sync) {
          updateEntry(args);
        }
        break;
      case "NEWE":
        if (comState == ComState.sync) {
          addEntry(args);
        }
        break;
      case "DONE":
        if (comState == ComState.sync) {
          comState = ComState.done;
        } else if (comState == ComState.done) {
          socket!.close();
          socket = null;
          comState = ComState.init;
        }
        break;
      case "NEWI":
        if (comState == ComState.sync || comState == ComState.done) {
          setIdExport(args);
        }
        break;
      default:
        break;
    }
  }

  /// format sent:
  ///    INFO + list of [id,lastModified;id,lastModified]
  Future<String> getSyncInfo() async {
    var entries = await api.getLogEntries();
    var exported = entries.where((e) => e.exportId != null);
    var exportedString = exported
        .map(
          (e) => "${e.exportId}$commaSeparator${e.lastModified}",
        )
        .join(pipeSeparator);
    var msg = "INFO$exportedString";
    return msg;
  }

  /// msg = list of id
  Future sendSync(String msg) async {
    var entries = await api.getLogEntries();
    // if updated asked, send updated entries
    if (msg != "") {
      var toSend = msg
          .split(commaSeparator)
          .map(
            (e) => int.parse(e),
          )
          .toList();

      // send UPDT + ExportId,lastModified,content
      for (var i in toSend) {
        var match = entries.where(((element) => element.exportId == i));
        if (match.isNotEmpty) {
          var e = match.first;
          sendMessage(
              "UPDT${e.exportId}$commaSeparator${e.lastModified}$commaSeparator${e.toCsvContent}");
        }
      }
    }

    //send NEWE + id,lastModified,content
    var missing = entries.where((e) => e.exportId == null);
    totNewEntries = missing.length;
    if (missing.isNotEmpty) {
      for (var e in missing) {
        sendMessage(
            "NEWE${e.id}$commaSeparator${e.lastModified}$commaSeparator${e.toCsvContent}");
      }
    } else {
      sendMessage("DONE");
    }

    sendMessage("DONE");
  }

  /// msg = id,exportId
  /// add exportId to entry
  /// if all entries have exportId, send DONE
  void setIdExport(String msg) async {
    var list = msg.split(commaSeparator);
    var id = int.parse(list[0]);
    var exportId = int.parse(list[1]);
    api.addExportId(id, exportId);
    if (--totNewEntries == 0) {
      sendMessage("DONE");
    }
  }

  /// add entry to entries
  void addEntry(String msg) async {
    var list = msg.split(commaSeparator);
    await api.addEntryFromServer(
        eid: int.parse(list[0]),
        lm: int.parse(list[1]),
        lf: LogFields(
          list[2],
          category: LogCategory.values[int.tryParse(list[4]) ?? 0],
          dc: DateTime.parse(list[3]),
        ));
  }

  /// update entry in entries
  Future updateEntry(String msg) async {
    var list = msg.split(commaSeparator);
    await api.updateEntryFromServer(
      eid: int.parse(list[0]),
      lm: int.parse(list[1]),
      lf: LogFields(
        list[2],
        category: LogCategory.values[int.parse(list[4])],
        dc: DateTime.parse(list[3]),
      ),
    );
  }

  Future deleteSyncData() async {
    await api.removeIdExport();
  }
}
