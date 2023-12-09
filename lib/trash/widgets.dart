import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:utils/time.dart';

import '../data/model.dart';

class LogTile extends StatelessWidget {
  final void Function(int) trashEntry;
  final void Function(String) copyEntry;
  final void Function(int) editCategory;
  final LogEntry entry;
  final Color color;
  final bool selected;

  const LogTile({
    required this.entry,
    required this.copyEntry,
    required this.trashEntry,
    this.color = Colors.white,
    required this.editCategory,
    this.selected = false,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) => copyEntry(entry.msg),
      onLongPress: () => editCategory(entry.id),
      child: ListTile(
        selectedColor: Colors.black,
        selected: selected,
        title: Text(entry.msg, style: const TextStyle(fontSize: 16)),
        subtitle: Text(dateTimeString(entry.time),
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
            color: Theme.of(context).colorScheme.primary,
            iconData: CupertinoIcons.arrow_clockwise,
            onLongPress: () {
              restoreEntry(entry.id);
              Navigator.pop(context);
            },
            onTap: () => restoreEntry(entry.id),
          ),
          LifeIconButton(
            color: Theme.of(context).colorScheme.primary,
            iconData: CupertinoIcons.delete,
            onTap: () => deleteEntry(entry.id),
            onLongPress: () => Navigator.pop(context),
          ),
        ],
      ),
      iconColor: Theme.of(context).colorScheme.primary,
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

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({required this.onSelection, super.key, this.selected});
  final void Function(LogCategory) onSelection;
  final LogCategory? selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var category in LogCategory.values)
          Expanded(
            flex: category == selected ? 1 : 5,
            child: InkWell(
              onTap: () {
                onSelection(category);
              },
              child: Center(
                  child: Column(
                children: [
                  Container(
                    color: category.color,
                    // width: 50,
                    height: 8,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    color: category.color,
                    // width: 50,
                    height: 8,
                  ),
                ],
              )),
            ),
          ),
      ],
    );
  }
}

class MyDivider extends StatelessWidget {
  const MyDivider(
      {required this.onDoubleTap,
      this.color,
      required this.onSwipe,
      super.key});
  final VoidCallback onDoubleTap;
  final VoidCallback onSwipe;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) => onSwipe(),
      onDoubleTap: onDoubleTap,
      child: Column(
        children: [
          Container(
            color: color,
            height: 8,
          ),
          const SizedBox(height: 5),
          Container(
            color: color,
            height: 8,
          ),
        ],
      ),
    );
  }
}
