import 'dart:async';

import 'package:core/database/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'model.dart';

class LogSqflTable extends IDatabaseTable {
  static LogSqflTable instance = LogSqflTable._();
  factory LogSqflTable() => instance;
  static String get tableName => 'logsql';

  static String get colMsg => IDatabaseTable.colEntryNotes;
  static String get colCategory => "category";

  LogSqflTable._()
      : super(
          tableName,
          [
            DatabaseColumnFields(
                name: colCategory, type: DatabaseColumnType.str, unique: false),
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
            version: 2,
            onCreate: _onCreate,
            onUpgrade: (db, oldVersion, newVersion) => db.execute(
                "ALTER TABLE ${table.name} ADD COLUMN ${LogSqflTable.colCategory} TEXT"),
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

  Stream<List<LogEntry>> getLogEntriesStream() {
    getLogEntries().then((value) => _logEntriesStreamController.add(value));
    return _logEntriesStreamController.stream;
  }

  Future<LogEntry> getLogEntry(int id) => _db.query(table.name,
      where: 'id = ?',
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

  Future deleteLogEntry(int id) => _db.delete(table.name,
      where: 'id = ?',
      whereArgs: [id]).then((value) => notifyLogEntries(value));

  Future<int> moveToTrash(int id) => getLogEntry(id)
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

  Future<int> restoreFromTrash(int id) => getLogEntry(id)
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

  void editCategory(int i, c) => _db
      .update(
        table.name,
        {LogSqflTable.colCategory: c.toString()},
        where: 'id = ?',
        whereArgs: [i],
      )
      .then(((value) => notifyLogEntries(value)));
}
