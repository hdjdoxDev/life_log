import 'dart:async';

import 'package:core/database/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'model.dart';

abstract class ILogApi {
  /// Get all log entries
  Future<List<LogEntry>> getLogEntries();

  /// Add a log entry
  Future<int> addLogEntry(LogFields entry);

  /// Get all log entries updated
  Stream<List<LogEntry>> getLogEntriesStream();

  static const String delPrefix = "x, ";

  moveToTrash(int id);

  void editCategory(int i, c);

  deleteLogEntry(int id);

  restoreFromTrash(int id);

  addEntryFromServer(
      {required int eid, required int lm, required LogFields lf});

  updateEntryFromServer(
      {required int eid, required int lm, required LogFields lf});

  void addExportId(int id, int exportId);

  Future removeIdExport();

  void deduplicate();
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
            version: 5,
            onCreate: _onCreate,
            onUpgrade: (db, oldVersion, newVersion) {},
          ).then((value) {
            // write here if you want to make changes to the database
            return value;
          }).then((value) => LogSqflApi._(value)));

  static Future<void> _onCreate(Database db, int version) async {
    db.execute(table.createSqflite);
    // on first run we can add some instructions as first logs
    // for (var lf in table.initialMsgs) {
    //   _addLogEntry(db, lf);
    // }
  }

  Future<int> flushAllData() => _db.delete(table.name);

  static Future<List<LogEntry>> _getLogEntries(Database db) => db
      .query(table.name, orderBy: IDatabaseTable.colLastModified)
      .then((value) => value.map((e) => LogEntry.fromTable(e)).toList());

  @override
  Future<List<LogEntry>> getLogEntries() => _getLogEntries(_db);

  @override
  Stream<List<LogEntry>> getLogEntriesStream() {
    getLogEntries().then((value) => _logEntriesStreamController.add(value));
    return _logEntriesStreamController.stream;
  }

  Future<LogEntry> getLogEntry(int id) => _db.query(table.name,
      where: '${IDatabaseTable.colId} = ?',
      whereArgs: [id]).then((value) => LogEntry.fromTable(value.first));

  Future<T> notifyLogEntries<T>(T ret) async {
    await getLogEntries().then((value) async {
      _logEntriesStreamController.add(value);
    });
    return ret;
  }

  static Future<int> _addLogEntry(Database db, LogFields lf) => db.insert(
        table.name,
        {
          ...lf.toTable(),
          IDatabaseTable.colLastModified: DateTime.now().millisecondsSinceEpoch
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  @override
  Future<int> addLogEntry(LogFields lf) =>
      _addLogEntry(_db, lf).then((value) => notifyLogEntries(value));

  @override
  Future deleteLogEntry(int id) => _db.delete(table.name,
      where: '${IDatabaseTable.colId} = ?',
      whereArgs: [id]).then((value) => notifyLogEntries(value));

  @override
  Future<int> moveToTrash(int id) => getLogEntry(id)
      .then((value) => _db.update(
            table.name,
            {
              ...value
                  .update(LogFields("${ILogApi.delPrefix}${value.msg}"))
                  .toTable(),
            },
            where: '${IDatabaseTable.colId} = ?',
            whereArgs: [id],
          ))
      .then((value) => notifyLogEntries(value));

  @override
  Future<int> restoreFromTrash(int id) => getLogEntry(id)
      .then((value) => _db.update(
          table.name,
          {
            ...value
                .update(value.msg.substring(ILogApi.delPrefix.length))
                .toTable(),
          },
          where: '${IDatabaseTable.colId} = ?',
          whereArgs: [id]))
      .then((value) => notifyLogEntries(value));

  @override
  void editCategory(int i, c) => _db
      .update(
        table.name,
        {LogSqflTable.colCategory: c.toString()},
        where: '${IDatabaseTable.colId} = ?',
        whereArgs: [i],
      )
      .then(((value) => notifyLogEntries(value)));

  @override
  addEntryFromServer(
          {required int eid, required int lm, required LogFields lf}) =>
      _db
          .insert(
            table.name,
            {
              ...lf.toTable(),
              IDatabaseTable.colLastModified: lm,
              IDatabaseTable.colExportId: eid,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          )
          .then((value) => notifyLogEntries(value));

  @override
  void addExportId(int id, int exportId) => _db.update(
        table.name,
        {IDatabaseTable.colExportId: exportId},
        where: '${IDatabaseTable.colId} = ?',
        whereArgs: [id],
      );

  @override
  updateEntryFromServer(
          {required int eid, required int lm, required LogFields lf}) =>
      _db
          .update(
            table.name,
            {
              ...lf.toTable(),
              IDatabaseTable.colLastModified: lm,
            },
            where: '${IDatabaseTable.colExportId} = ?',
            whereArgs: [eid],
          )
          .then((value) => notifyLogEntries(value));

  @override
  Future removeIdExport() => _db.update(
        table.name,
        {IDatabaseTable.colExportId: null},
      );

  @override
  void deduplicate() {
    getLogEntries().then((value) {
      var map = <String, List<LogEntry>>{};
      for (var e in value) {
        if (map.containsKey(e.msg)) {
          map[e.msg]!.add(e);
        } else {
          map[e.msg] = [e];
        }
      }
      for (var e in map.entries) {
        if (e.value.length > 1) {
          for (var i = 1; i < e.value.length; i++) {
            moveToTrash(e.value[i].id);
          }
        }
      }
    });
  }
}
