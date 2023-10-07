import 'package:flutter/material.dart';
import 'model.dart';

class LogTile extends StatelessWidget {
  const LogTile(this.entry, {super.key});
  final LogEntry entry;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("id: ${entry.id} -> ${entry.exportId}"),
        Text("msg: ${entry.msg}"),
        Text("category: ${entry.category}"),
        Text("dateCreated: ${entry.dateCreated.day}"),
        Text("lastModified: ${entry.lastModified.day}"),
        const SizedBox(height: 8),
      ],
    );
  }
}
