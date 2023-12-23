import 'package:life_log/log/viewmodel.dart';

import '../data/model.dart';
import '../data/sqfl.dart';

class LogTrashModel extends LogModel {
  @override
  List<LogEntry> get results => entries
      .where((e) => e.msg.contains(query))
      .where((e) => e.msg.startsWith(ILogApi.delPrefix))
      .toList();

  Future restoreLog(int id) => api.restoreFromTrash(id);
}
