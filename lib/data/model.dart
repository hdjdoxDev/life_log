import 'package:core/database/database.dart';
import 'package:flutter/material.dart';
import 'package:utils/stringify.dart';
import 'package:utils/time.dart';

import '../share/viewmodel.dart';

// Enums and Classes relative to log

class LogFields implements ISqflFields {
  String msg = "";
  LogCategory category = LogCategory.all;
  DateTime? dateCreated;

  LogFields(this.msg, {this.category = LogCategory.all, this.dateCreated});

  @override
  Map<String, Object?> toTable() => {
        LogSqflTable.colMsg: msg,
        LogSqflTable.colCategory: category.toString(),
        if (dateCreated != null)
          LogSqflTable.colDateCreated: dateCreated!.millisecondsSinceEpoch,
      };

  //from table
  @override
  LogFields.fromTable(Map<String, dynamic> map)
      : msg = map[LogSqflTable.colMsg],
        category = LogCategory.values.firstWhere(
            (e) => e.toString() == map[LogSqflTable.colCategory],
            orElse: () => LogCategory.all),
        dateCreated = DateTime.fromMillisecondsSinceEpoch(
            map[LogSqflTable.colDateCreated] ?? 0);

  @override
  IFields update(fields) {
    if (fields is LogFields) {
      msg = fields.msg;
      category = fields.category;
      dateCreated = fields.dateCreated;
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

  LogEntry.fromFields(LogFields sf, this.id, this.exportId, this.lastModified)
      : super(sf.msg, category: sf.category, dateCreated: sf.dateCreated);

  LogEntry.fromTable(Map<String, dynamic> map)
      : id = map[IDatabaseTable.colId],
        lastModified = map[IDatabaseTable.colLastModified],
        exportId = map[IDatabaseTable.colExportId],
        super.fromTable(map);

  DateTime get time => dateCreated ?? DateTime(2015, 23, 12);

  String get readableTime =>
      "${dateTimeString(time)} - ${weekDaysShort(time.weekday)}";

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
                name: colDateCreated, type: DatabaseColumnType.int),
          ],
          addSuggested: true,
        );

  List<LogFields> get initialMsgs => [
        "Hi! We are log entries :)",
        "Down there you can type more :3",
        "That trash can on our right kills us :(",
        "Long press on it to see the cimitery",
        "To activate search mode you need to find the gray lens",
      ].map((e) => LogFields(e, dateCreated: now)).toList();
}

enum LogCategory {
  all,
  yellow,
  red,
  green,
  blue,
  purple,
  orange;

  static List<LogCategory> get orderedValues => [
        green,
        blue,
        purple,
        all,
        red,
        yellow,
        orange,
      ];

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
        return Colors.white;
    }
  }
}
