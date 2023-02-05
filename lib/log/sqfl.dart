import 'dart:async';

import 'package:mypack/core/models/database.dart';
import 'package:mypack/utils/time.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'model.dart';

class LogSqflTable extends IDatabaseTable {
  static LogSqflTable instance = LogSqflTable._();
  factory LogSqflTable() => instance;
  static String get tableName => 'logsql';

  static String get colMsg => IDatabaseTable.colEntryNotes;

  LogSqflTable._()
      : super(
          tableName,
          [],
          addSuggested: true,
        );

  List<LogFields> get initialMsgs => [
        LogFields("Hi! We are log entries :)"),
        LogFields("Down there you can type more :3"),
        LogFields("That trash can on our right kills us :("),
        LogFields("Long press on it to see the cimitery"),
        LogFields("activate search mode you need to find the gray")
      ];
}

class LogSqflApi implements ILogApi {
  LogSqflApi._(this._db);

  static LogSqflTable table = LogSqflTable();

  static const _dbName = 'log.db';

  final Database _db;
  final StreamController<List<LogEntry>> _logEntriesStreamController =
      StreamController.broadcast();

  static Future<LogSqflApi> init() =>
      getDatabasesPath().then((path) => openDatabase(
            p.join(path, _dbName),
            version: 1,
            onCreate: _onCreate,
          ).then((value) => LogSqflApi._(value)));

  static Future<void> _onCreate(Database db, int version) async {
    if (version == 1) {
      db.execute(table.createSqflite);
      for (var lf in table.initialMsgs) {
        _addLogEntry(db, lf);
      }
    }
  }

  Future<int> flushAllData() => _db.delete(table.name);

  static Future<List<LogEntry>> _getLogEntries(Database db) => db
      .query(table.name, orderBy: IDatabaseTable.colLastModified)
      .then((value) => value.map((e) => LogEntry.fromTable(e)).toList());
  @override
  Future<List<LogEntry>> getLogEntries() => _getLogEntries(_db);

  static Stream<List<LogEntry>> _getLogEntriesStream(Database db) => db
      .query(table.name, orderBy: IDatabaseTable.colLastModified)
      .asStream()
      .map((value) => value.map((e) => LogEntry.fromTable(e)).toList());

  Stream<List<LogEntry>> getLogEntriesStream() => _getLogEntriesStream(_db);

  Future<LogEntry> getLogEntry(int id) => _db.query(table.name,
      where: 'id = ?',
      whereArgs: [id]).then((value) => LogEntry.fromTable(value.first));

  Future<T> notifyLogEntries<T>(T ret) => getLogEntries()
      .then((value) => _logEntriesStreamController.add(value))
      .then((_) => ret);

  static Future<int> _addLogEntry(Database db, LogFields lf) => db.insert(
        table.name,
        {
          ...lf.toTable(),
          IDatabaseTable.colLastModified: now.millisecondsSinceEpoch
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  @override
  Future<int> addLogEntry(LogFields lf) =>
      _addLogEntry(_db, lf).then((value) => notifyLogEntries(value));

  Future deleteLogEntry(int id) => _db.delete(table.name,
      where: 'id = ?',
      whereArgs: [id]).then((value) => notifyLogEntries(value));

  Future<int> setDeleted(int id) => getLogEntry(id)
      .then((value) => _db.update(
            table.name,
            {
              ...value
                  .update(LogFields("${ILogApi.delPrefix}${value.msg}"))
                  .toTable(),
            },
            where: 'id = ?',
            whereArgs: [id],
          ))
      .then((value) => notifyLogEntries(value));

  Future<int> restoreTrashed(int id) => getLogEntry(id)
      .then((value) => _db.update(
          table.name,
          {
            ...value
                .update(value.msg.substring(ILogApi.delPrefix.length))
                .toTable(),
          },
          where: 'id = ?',
          whereArgs: [id]))
      .then((value) => notifyLogEntries(value));
}
