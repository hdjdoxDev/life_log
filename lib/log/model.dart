import 'package:core/database/database.dart';

import 'sqfl.dart';

// Enums and Classes relative to log

class LogFields implements ISqflFields {
  String msg = "";

  LogFields(this.msg);

  @override
  Map<String, Object?> toTable() => {
        LogSqflTable.colMsg: msg,
      };

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
      required int lastModified})
      : _id = id,
        _exportId = exportId,
        _lastModified = lastModified,
        super(msg);

  LogEntry.fromFields(LogFields sf, id, exportId, lastModified)
      : _id = id,
        _exportId = exportId,
        _lastModified = lastModified,
        super(sf.msg);

  LogEntry.fromTable(Map<String, dynamic> map)
      : _id = map[IDatabaseTable.colId],
        _lastModified = map[IDatabaseTable.colLastModified],
        _exportId = map[IDatabaseTable.colExportId],
        super(map[LogSqflTable.colMsg]);

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
