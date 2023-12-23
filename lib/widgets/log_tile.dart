import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/model.dart';
import 'life_icon_button.dart';

class LogTile extends StatelessWidget {
  final void Function(int) trashEntry;
  final void Function(String) copyEntry;
  final void Function(LogEntry) selectLog;
  final LogEntry entry;
  final bool selected;

  const LogTile({
    required this.entry,
    required this.copyEntry,
    required this.trashEntry,
    required this.selectLog,
    this.selected = false,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) => copyEntry(entry.msg),
      onLongPress: () => selectLog(entry),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 16),
        selectedColor: Colors.black,
        selected: selected,
        title: Text(entry.msg, style: const TextStyle(fontSize: 16)),
        subtitle: Text(entry.readableTime,
            style: TextStyle(fontSize: 10, color: entry.category.color)),
        trailing: LifeIconButton(
          color: entry.category.color,
          iconData: CupertinoIcons.delete,
          onLongPress: () => Navigator.pushNamed(context, '/trash'),
          onTap: () => trashEntry(entry.id),
        ),
      ),
    );
  }
}
