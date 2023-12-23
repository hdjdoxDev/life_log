import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:utils/time.dart';

import '../data/model.dart';
import 'life_icon_button.dart';

class LogTrashTile extends StatelessWidget {
  final LogEntry entry;
  final Future Function(int) restoreEntry;
  final void Function(int)? deleteEntry;
  const LogTrashTile({
    required this.entry,
    required this.restoreEntry,
    this.deleteEntry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entry.msg, style: const TextStyle(fontSize: 16)),
      subtitle: Text(dateTimeString(entry.time),
          style: const TextStyle(fontSize: 10)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LifeIconButton(
            color: Theme.of(context).colorScheme.primary,
            iconData: CupertinoIcons.arrow_clockwise,
            onLongPress: () => restoreEntry(entry.id),
            onTap: () =>
                restoreEntry(entry.id).then((value) => Navigator.pop(context)),
          ),
        ],
      ),
      iconColor: Theme.of(context).colorScheme.primary,
    );
  }
}
