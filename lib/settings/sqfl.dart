import 'dart:async';

import 'package:life_log/settings/viewmodel.dart';
import 'package:mypack/core/models/database.dart';
import 'package:mypack/core/models/database_column.dart';
import 'package:mypack/utils/time.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../login/viewmodel.dart';
import 'model.dart';

class SettingsSqflTable extends IDatabaseTable {
  static SettingsSqflTable instance = SettingsSqflTable._();
  factory SettingsSqflTable() => instance;
  static String get tableName => 'settings';

  static String get colMsg => IDatabaseTable.colEntryNotes;
  static String get colName => "name";

  SettingsSqflTable._()
      : super(tableName, addSuggested: true, [
          DatabaseColumnFields(
              name: colName, type: DatabaseColumnType.str, unique: true)
        ]);

  List<SettingsFields> get initialSettings => [
        SettingsFields(
            ISettingsApi.colorName, "${SettingsModel.defaultColorIndex}"),
        SettingsFields(ISettingsApi.userName, LoginModel.defaultUser),
        SettingsFields(ISettingsApi.passName, LoginModel.defaultPass),
        SettingsFields(ISettingsApi.totalName, "0"),
        SettingsFields(ISettingsApi.trashName, "0"),
        SettingsFields(ISettingsApi.loggedName, "0")
      ];
}

class SettingsSqflApi implements ISettingsApi {
  SettingsSqflApi._(this._db);

  static SettingsSqflTable table = SettingsSqflTable();

  static const _dbName = 'settings.db';

  final Database _db;
  final StreamController<List<SettingsEntry>> _settingsEntriesStreamController =
      StreamController.broadcast();

  static Future<SettingsSqflApi> init() =>
      getDatabasesPath().then((path) => openDatabase(
            p.join(path, _dbName),
            version: 1,
            onCreate: _onCreate,
          ).then((value) => SettingsSqflApi._(value)));

  static Future<void> _onCreate(Database db, int version) async {
    if (version == 1) {
      db.execute(table.createSqflite);
      for (var lf in table.initialSettings) {
        _addSettingsEntry(db, lf);
      }
    }
  }

  Future<int> flushAllData() => _db.delete(table.name);

  static Future<List<SettingsEntry>> _getSettingsEntries(Database db) => db
      .query(table.name, orderBy: IDatabaseTable.colLastModified)
      .then((value) => value.map((e) => SettingsEntry.fromTable(e)).toList());

  Future<List<SettingsEntry>> getSettingsEntries() => _getSettingsEntries(_db);

  Stream<List<SettingsEntry>> getSettingsEntriesStream() {
    getSettingsEntries()
        .then((value) => _settingsEntriesStreamController.add(value));
    return _settingsEntriesStreamController.stream;
  }

  Future<SettingsEntry> getSettingsEntry(int id) => _db.query(table.name,
      where: '${IDatabaseTable.colId} = ?',
      whereArgs: [id]).then((value) => SettingsEntry.fromTable(value.first));

  Future<T> notifySettingsEntries<T>(T ret) => getSettingsEntries()
      .then((value) => _settingsEntriesStreamController.add(value))
      .then((_) => ret);

  static Future<int> _addSettingsEntry(Database db, SettingsFields lf) =>
      db.insert(
        table.name,
        {
          ...lf.toTable(),
          IDatabaseTable.colLastModified: now.millisecondsSinceEpoch
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<int> addSettingsEntry(SettingsFields lf) =>
      _addSettingsEntry(_db, lf).then((value) => notifySettingsEntries(value));

  Future deleteSettingsEntry(int id) => _db.delete(table.name,
      where: 'id = ?',
      whereArgs: [id]).then((ret) => notifySettingsEntries(ret));

  Future<int> setSetting(String name, String msg) => _db
      .delete(table.name,
          where: "${SettingsSqflTable.colName} = ?", whereArgs: [name])
      .then((_) => _addSettingsEntry(_db, SettingsFields(name, msg)))
      .then((ret) => notifySettingsEntries(ret));

  Future<String> getSetting(String key) =>
      getSettingsEntries().then((value) => value
          .lastWhere((element) => element.msg.startsWith(key))
          .msg
          .split(", ")[1]);

  Future<bool> matchSetting(String key, String value) => _db.rawQuery(
      "SELECT 1 FROM ${table.name} WHERE ${SettingsSqflTable.colName} = '?' AND ${SettingsSqflTable.colMsg} = '?'",
      [key, value]).then((value) => value.isNotEmpty);

  Future<int> setLoggedIn() => setSetting(ISettingsApi.loggedName, "1");

  Future<int> setLoggedOut() => setSetting(ISettingsApi.loggedName, "0");
}
