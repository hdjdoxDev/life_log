import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypack/utils/time.dart';

import 'model.dart';

class LoginTile extends StatelessWidget {
  const LoginTile({
    required this.entry,
    required this.copyEntry,
    required this.deleteEntry,
    super.key,
  });
  final void Function(String) copyEntry;
  final void Function(int) deleteEntry;
  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) => copyEntry(entry.msg),
      child: ListTile(
        title: Text(entry.msg, style: const TextStyle(fontSize: 16)),
        subtitle: Text(dateTimeString(entry.time),
            style: const TextStyle(fontSize: 10)),
        trailing: LifeIconButton(
          color: Theme.of(context).colorScheme.secondary,
          iconData: CupertinoIcons.delete,
          onTap: () => deleteEntry(entry.id),
        ),
      ),
    );
  }
}

class LogTile extends StatelessWidget {
  final void Function(int) trashEntry;
  final void Function(String) copyEntry;
  final LogEntry entry;

  const LogTile({
    required this.entry,
    required this.copyEntry,
    required this.trashEntry,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) => copyEntry(entry.msg),
      child: ListTile(
        title: Text(entry.msg, style: const TextStyle(fontSize: 16)),
        subtitle: Text(dateTimeString(entry.time),
            style: const TextStyle(fontSize: 10)),
        trailing: LifeIconButton(
          color: Theme.of(context).colorScheme.secondary,
          iconData: CupertinoIcons.delete,
          onLongPress: () => Navigator.pushNamed(context, '/trash'),
          onTap: () => trashEntry(entry.id),
        ),
      ),
    );
  }
}

class LogTrashTile extends StatelessWidget {
  final LogEntry entry;
  final void Function(int) restoreEntry;
  final void Function(int) deleteEntry;
  const LogTrashTile({
    required this.entry,
    required this.restoreEntry,
    required this.deleteEntry,
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
            color: Theme.of(context).colorScheme.secondary,
            iconData: CupertinoIcons.arrow_clockwise,
            onLongPress: () {
              restoreEntry(entry.id);
              Navigator.pop(context);
            },
            onTap: () => restoreEntry(entry.id),
          ),
          LifeIconButton(
            color: Theme.of(context).colorScheme.secondary,
            iconData: CupertinoIcons.delete,
            onTap: () => deleteEntry(entry.id),
            onLongPress: () => Navigator.pop(context),
          ),
        ],
      ),
      iconColor: Theme.of(context).colorScheme.secondary,
    );
  }
}

class LifeIconButton extends StatelessWidget {
  const LifeIconButton({
    super.key,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    required this.color,
    required this.iconData,
  });
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final Color color;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        padding: const EdgeInsets.all(10),
        child: Icon(iconData, color: color),
      ),
    );
  }
}
