import 'package:core/database/database.dart';
import 'package:flutter/material.dart';

import '../share/viewmodel.dart';

// Enums and Classes relative to log

class LogFields implements ISqflFields {
  String msg = "";
  LogCategory category = LogCategory.all;
  DateTime dateCreated = DateTime.now();

  LogFields(this.msg, {this.category = LogCategory.all, DateTime? dc, n})
      : dateCreated = dc ?? DateTime.now();

  @override
  Map<String, Object?> toTable() => {
        LogSqflTable.colMsg: msg,
        LogSqflTable.colCategory: category.toString(),
        LogSqflTable.colDateCreated: dateCreated.millisecondsSinceEpoch,
      };

  //from table
  @override
  LogFields.fromTable(Map<String, dynamic> map)
      : msg = map[LogSqflTable.colMsg],
        category = LogCategory.values.firstWhere(
            (e) => e.toString() == map[LogSqflTable.colCategory],
            orElse: () => LogCategory.all),
        dateCreated =
            DateTime.tryParse(map[LogSqflTable.colDateCreated] ?? "") ??
                DateTime.now();

  @override
  IFields update(fields) {
    if (fields is LogFields) {
      msg = fields.msg;
    }
    return this;
  }
}

class LogEntry extends LogFields implements ISqflEntry {
  @override
  final int id;
  @override
  int? exportId;
  @override
  int lastModified;
  @override
  String entryNotes = "";

  @override
  LogFields get fields => this;

  LogEntry(
      {required String msg,
      required this.id,
      this.exportId,
      required this.lastModified,
      LogCategory category = LogCategory.all})
      : super(msg, category: category, dc: DateTime.now());

  LogEntry.fromFields(LogFields sf, this.id, this.exportId, this.lastModified)
      : super(sf.msg, category: sf.category, dc: sf.dateCreated);

  LogEntry.fromTable(Map<String, dynamic> map)
      : id = map[IDatabaseTable.colId],
        lastModified = map[IDatabaseTable.colLastModified],
        exportId = map[IDatabaseTable.colExportId],
        super.fromTable(map);

  DateTime? get time => DateTime.fromMillisecondsSinceEpoch(lastModified);

  @override
  Map<String, Object?> toTable() => {
        IDatabaseTable.colId: id,
        IDatabaseTable.colExportId: exportId,
        IDatabaseTable.colLastModified: lastModified,
        ...super.toTable(),
      };

  @override
  LogEntry update(dynamic fields) {
    super.update(fields);
    return this;
  }

  static String get csvHeaderContent => [
        "msg",
        "dateCreated",
        "category",
      ].join(commaSeparator);

  String get toCsvContent => [
        msg,
        dateCreated,
        category.index,
      ].join(commaSeparator);
}


class LogSqflTable extends IDatabaseTable {
  static LogSqflTable instance = LogSqflTable._();
  factory LogSqflTable() => instance;
  static String get tableName => 'logsql';

  static String get colMsg => IDatabaseTable.colEntryNotes;
  static String get colDateCreated => "dateCreated";
  static String get colCategory => "category";

  LogSqflTable._()
      : super(
          tableName,
          [
            DatabaseColumnFields(
                name: colCategory, type: DatabaseColumnType.str, unique: false),
            DatabaseColumnFields(
                name: colDateCreated, type: DatabaseColumnType.str),
          ],
          addSuggested: true,
        );

  List<LogFields> get initialMsgs => [
        LogFields("Hi! We are log entries :)"),
        LogFields("Down there you can type more :3"),
        LogFields("That trash can on our right kills us :("),
        LogFields("Long press on it to see the cimitery"),
        LogFields("To activate search mode you need to find the gray lens"),
      ];
}

enum LogCategory {
  all,
  yellow,
  red,
  green,
  blue,
  purple,
  orange;

  Color get color {
    switch (this) {
      case LogCategory.yellow:
        return Colors.yellow;
      case LogCategory.red:
        return Colors.red;
      case LogCategory.green:
        return Colors.green;
      case LogCategory.blue:
        return Colors.blue;
      case LogCategory.purple:
        return Colors.purple;
      case LogCategory.orange:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
