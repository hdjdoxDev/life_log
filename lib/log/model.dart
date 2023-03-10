import 'package:mypack/core/models/database.dart';
import 'package:mypack/core/models/sqfl.dart';

import 'sqfl.dart';

// Enums and Classes relative to log

class LogFields implements ISqflEntryFields {
  String msg = "";

  LogFields(this.msg);

  @override
  Map<String, Object?> toTable() => {
        LogSqflTable.colMsg: msg,
      };
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
      required int lastModified})
      : _id = id,
        _exportId = exportId,
        _lastModified = lastModified,
        super(msg);

  LogEntry.fromTable(Map<String, dynamic> map)
      : _id = map[IDatabaseTable.colId],
        _lastModified = map[IDatabaseTable.colLastModified],
        _exportId = map[IDatabaseTable.colExportId],
        super(map[LogSqflTable.colMsg]);

  @override
  Map<String, Object?> toTable() => {
        IDatabaseTable.colId: _id,
        IDatabaseTable.colExportId: _exportId,
        IDatabaseTable.colLastModified: _lastModified,
        ...super.toTable(),
      };

  DateTime? get time => DateTime.fromMillisecondsSinceEpoch(_lastModified);

  LogEntry update(dynamic fields) {
    if (fields is LogFields) {
      msg = fields.msg;
    } else if (fields is Map<String, dynamic> &&
        fields.containsKey(LogSqflTable.colMsg)) {
      msg = fields[LogSqflTable.colMsg];
    } else if (fields is String) {
      msg = fields;
    }
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
