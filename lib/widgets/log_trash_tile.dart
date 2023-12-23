import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/model.dart';
import 'life_icon_button.dart';

class LogTrashTile extends StatelessWidget {
  final LogEntry entry;
  final Future Function(int) restoreEntry;
  final Color color;

  const LogTrashTile({
    required this.entry,
    required this.restoreEntry,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 16),
      title: Text(entry.msg, style: const TextStyle(fontSize: 16)),
      subtitle: Text(
        entry.readableTime,
        style: const TextStyle(fontSize: 10),
      ),
      trailing: LifeIconButton(
        color: color,
        iconData: CupertinoIcons.arrow_clockwise,
        onLongPress: () => restoreEntry(entry.id),
        onTap: () =>
            restoreEntry(entry.id).then((value) => Navigator.pop(context)),
      ),
    );
  }
}
