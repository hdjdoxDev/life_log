import 'dart:convert';

class LogEntry {
  int id;
  String msg;
  DateTime dateCreated;
  String category;

  int? exportId;
  DateTime lastModified;

  LogEntry({
    required this.id,
    required this.msg,
    required this.dateCreated,
    required this.category,
    required this.exportId,
    required this.lastModified,
  });

  LogEntry copyWith({
    int? id,
    String? msg,
    DateTime? dateCreated,
    String? category,
    int? exportId,
    DateTime? lastModified,
  }) {
    return LogEntry(
      id: id ?? this.id,
      msg: msg ?? this.msg,
      dateCreated: dateCreated ?? this.dateCreated,
      category: category ?? this.category,
      exportId: exportId ?? this.exportId,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'msg': msg,
      'dateCreated': dateCreated.millisecondsSinceEpoch,
      'category': category,
      'exportId': exportId,
      'lastModified': lastModified.millisecondsSinceEpoch,
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'] as int,
      msg: map['msg'] as String,
      dateCreated:
          DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] as int),
      category: map['category'] as String,
      exportId: map['exportId'] as int,
      lastModified:
          DateTime.fromMillisecondsSinceEpoch(map['lastModified'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory LogEntry.fromJson(String source) =>
      LogEntry.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant LogEntry other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.msg == msg &&
        other.dateCreated == dateCreated &&
        other.category == category &&
        other.exportId == exportId &&
        other.lastModified == lastModified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        msg.hashCode ^
        dateCreated.hashCode ^
        category.hashCode ^
        exportId.hashCode ^
        lastModified.hashCode;
  }

  static List<String> get csvHeaderList => [
        'msg',
        'dateCreated',
        'category',
      ];
  static String get csvHeader => csvHeaderList.join(',');
  get content => "$msg,$dateCreated,$category";
}
