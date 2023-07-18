import 'package:core/database/database.dart';
import 'package:flutter/material.dart';

import 'sqfl.dart';

// Enums and Classes relative to log

class LogFields implements ISqflFields {
  String msg = "";
  LogCategory category = LogCategory.all;

  LogFields(this.msg, {this.category = LogCategory.all});

  @override
  Map<String, Object?> toTable() => {
        LogSqflTable.colMsg: msg,
        LogSqflTable.colCategory: category.toString(),
      };

  //from table
  @override
  LogFields.fromTable(Map<String, dynamic> map)
      : msg = map[LogSqflTable.colMsg],
        category = LogCategory.values.firstWhere(
            (e) => e.toString() == map[LogSqflTable.colCategory],
            orElse: () => LogCategory.all);

  @override
  IFields update(fields) {
    if (fields is LogFields) {
      msg = fields.msg;
    }
    return this;
  }
}

class LogEntry extends LogFields implements ISqflEntry {
  final int _id;
  final int? _exportId;
  final int _lastModified;

  @override
  int get id => _id;
  @override
  int? get exportId => _exportId;
  @override
  String get entryNotes => msg;
  @override
  int get lastModified => _lastModified;

  @override
  LogFields get fields => this;

  LogEntry(
      {required String msg,
      required id,
      int? exportId,
      required int lastModified,
      LogCategory category = LogCategory.all})
      : _id = id,
        _exportId = exportId,
        _lastModified = lastModified,
        super(msg, category: category);

  LogEntry.fromFields(LogFields sf, id, exportId, lastModified)
      : _id = id,
        _exportId = exportId,
        _lastModified = lastModified,
        super(sf.msg, category: sf.category);

  LogEntry.fromTable(Map<String, dynamic> map)
      : _id = map[IDatabaseTable.colId],
        _lastModified = map[IDatabaseTable.colLastModified],
        _exportId = map[IDatabaseTable.colExportId],
        super.fromTable(map);

  DateTime? get time => DateTime.fromMillisecondsSinceEpoch(_lastModified);

  @override
  Map<String, Object?> toTable() => {
        IDatabaseTable.colId: _id,
        IDatabaseTable.colExportId: _exportId,
        IDatabaseTable.colLastModified: _lastModified,
        ...super.toTable(),
      };

  @override
  LogEntry update(dynamic fields) {
    super.update(fields);
    return this;
  }
}

abstract class ILogApi {
  /// Get all log entries
  Future<List<LogEntry>> getLogEntries();

  /// Add a log entry
  Future<int> addLogEntry(LogEntry entry);

  static const String delPrefix = "x, ";
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
