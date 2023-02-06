import 'package:life_log/log/viewmodel.dart';

import 'model.dart';

class LogTrashModel extends LogModel {
  @override
  List<LogEntry> get results => entries
      .where((e) => e.msg.contains(query))
      .where((e) => e.msg.startsWith(ILogApi.delPrefix))
      .toList();

  Future deleteLog(int id) => api.deleteLogEntry(id);

  Future restoreLog(int id) => api.restoreFromTrash(id);
}
