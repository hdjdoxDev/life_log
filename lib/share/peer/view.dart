import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'model.dart';
import 'widget.dart';

class PeerView extends StatefulWidget {
  const PeerView(this.peer, {super.key});
  final int peer;
  @override
  State<PeerView> createState() => _PeerViewState();
}

class _PeerViewState extends State<PeerView> {
  Socket? socket;
  
  List<LogEntry> entries = [];

  String ip = "10.1.205.249";
  int port = 4646;

  ComState comState = ComState.init;
  @override
  void initState() {
    super.initState();
    if (widget.peer == 1) {
      entries = [
        LogEntry(
          id: 0,
          msg: 'apple',
          dateCreated: DateTime(2023, 1, 1),
          category: "company",
          exportId: null,
          lastModified: DateTime(2023, 1, 2),
        ),
        LogEntry(
          id: 1,
          msg: 'banana',
          dateCreated: DateTime(2023, 1, 1),
          category: "fruit",
          exportId: null,
          lastModified: DateTime(2023, 1, 1),
        ),
      ];
    } else {
      entries = [
        LogEntry(
          id: 0,
          msg: 'clown',
          dateCreated: DateTime(2023, 1, 1),
          category: "hero",
          exportId: null,
          lastModified: DateTime(2023, 1, 2),
        ),
        LogEntry(
          id: 1,
          msg: 'drawing',
          dateCreated: DateTime(2023, 1, 1),
          category: "art",
          exportId: null,
          lastModified: DateTime(2023, 1, 1),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text('PeerView'),
          Text('entries: ${entries.length}'),
          const SizedBox(height: 8),
          for (var i = 0; i < entries.length; i++) LogTile(entries[i]),
          const SizedBox(height: 8),
          Text('ip: $ip'),
          Text('port: $port'),
          ElevatedButton(
            onPressed: () => startSink(),
            child: const Text('startSink'),
          ),
        ],
      ),
    );
  }

  void startSink() async {
    comState = ComState.sync;

    socket = await Socket.connect(ip, port);
    socket!.listen(onData);

    socket!.write("SYNC\n");
    socket!.write("HEAD${LogEntry.csvHeader}\n");
    socket!.write(getSyncInfo());
    socket!.write("DONE");
  }

  void onData(Uint8List data) async {
    var dataString = String.fromCharCodes(data);
    var lines = dataString.split('\n');

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
    print("C recv in $comState: <$comm + $args>");

    switch (comm) {
      case "ASKE":
        if (comState == ComState.sync) {
          sendSink(args);
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
  String getSyncInfo() {
    var exported = entries.where((e) => e.exportId != null);
    var exportedString = exported
        .map(
          (e) => "${e.exportId},${e.lastModified.millisecondsSinceEpoch}",
        )
        .join(";");
    var msg = "INFO$exportedString\n";
    return msg;
  }

  /// msg = list of id
  void sendSink(String msg) {
    // if updated asked, send updated entries
    if (msg != "") {
      var toSend = msg
          .split(',')
          .map(
            (e) => int.parse(e),
          )
          .toList();

      // send UPDT + ExportId,lastModified,content
      for (var i in toSend) {
        var match = entries.where(((element) => element.exportId == i));
        if (match.isNotEmpty) {
          var e = match.first;
          socket!.write(
              "UPDT${e.exportId},${e.lastModified.millisecondsSinceEpoch},${e.content}\n");
        }
      }
    }

    //send NEWE + id,lastModified,content
    var missing = entries.where((e) => e.exportId == null);
    if (missing.isNotEmpty) {
      for (var e in missing) {
        socket!.write(
            "NEWE${e.id},${e.lastModified.millisecondsSinceEpoch},${e.content}\n");
      }
    } else {
      socket!.write("DONE\n");
    }

    socket!.write("DONE\n");
  }

  /// msg = id,exportId
  /// add exportId to entry
  /// if all entries have exportId, send DONE
  void setIdExport(String msg) {
    var list = msg.split(",");
    var id = int.parse(list[0]);
    var exportId = int.parse(list[1]);
    for (var e in entries) {
      if (e.id == id) e.exportId = exportId;
    }
    if (comState == ComState.done &&
        entries.where((e) => e.exportId == null).isEmpty) {
      socket!.write("DONE\n");
    }
    setState(() {
      entries = entries;
    });
  }

  /// add entry to entries
  void addEntry(String msg) {
    print("addEntry: $msg");
    var list = msg.split(",");
    entries.add(
      LogEntry(
        id: entries.length,
        lastModified: DateTime.fromMillisecondsSinceEpoch(
          int.parse(list[1]),
        ),
        msg: list[2],
        category: list[4],
        dateCreated: DateTime.parse(list[3]),
        exportId: int.parse(list[0]),
      ),
    );
    setState(() {
      entries = entries;
    });
  }

  /// update entry in entries
  void updateEntry(String msg) {
    var list = msg.split(",");
    for (var e in entries) {
      if (e.exportId == int.parse(list[0])) {
        e.msg = list[2];
        e.category = list[4];
        e.lastModified = DateTime.fromMillisecondsSinceEpoch(
          int.parse(list[1]),
        );
        e.dateCreated = DateTime.parse(list[3]);
      }
    }
    setState(() {
      entries = entries;
    });
  }
}

enum ComState {
  init,
  sync,
  done,
}
