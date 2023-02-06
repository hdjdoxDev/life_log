import 'package:mypack/core/models/database.dart';
import 'package:mypack/core/models/sqfl.dart';

import 'sqfl.dart';
// Enums and Classes relative to Settings

class SettingsFields implements ISqflEntryFields {
  String msg = "";
  String name = "";
  SettingsFields(
    this.name,
    this.msg,
  );

  @override
  Map<String, Object?> toTable() => {
        SettingsSqflTable.colName: name,
        SettingsSqflTable.colMsg: msg,
      };
}

class SettingsEntry extends SettingsFields implements ISqflEntry {
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
  SettingsFields get fields => this;

  SettingsEntry({name, msg, id, exportId, lastModified})
      : _id = id,
        _exportId = exportId,
        _lastModified = lastModified,
        super(name, msg);

  SettingsEntry.fromTable(Map<String, dynamic> map)
      : _id = map[IDatabaseTable.colId],
        _lastModified = map[IDatabaseTable.colLastModified],
        _exportId = map[IDatabaseTable.colExportId],
        super(map[SettingsSqflTable.colName], map[SettingsSqflTable.colMsg]);

  @override
  Map<String, Object?> toTable() => {
        IDatabaseTable.colId: _id,
        IDatabaseTable.colExportId: _exportId,
        IDatabaseTable.colLastModified: _lastModified,
        ...super.toTable(),
      };

  DateTime? get time => DateTime.fromMillisecondsSinceEpoch(_lastModified);

  SettingsEntry update(dynamic fields) {
    if (fields is SettingsFields) {
      name = fields.name;
      msg = fields.msg;
    } else if (fields is Map<String, dynamic> &&
        fields.containsKey(SettingsSqflTable.colName) &&
        fields.containsKey(SettingsSqflTable.colMsg)) {
      name = fields[SettingsSqflTable.colName];
      msg = fields[SettingsSqflTable.colMsg];
    } else if (fields is List<String>) {
      name = fields[0];
      msg = fields[1];
    }
    return this;
  }
}

abstract class ISettingsApi {
  /// Get all Settings entries
  Future<List<SettingsEntry>> getSettingsEntries();

  /// Add a Settings entry
  Future<int> addSettingsEntry(SettingsEntry entry);

  static const String colorName = "color";
  static const String userName = "user";
  static const String passName = "pass";
  static const String serverName = "server";
  static const String portName = "port";
  static const String totalName = "total";
  static const String trashName = "trash";
}
