import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mypack/ui/views/base_view.dart';

import 'package:mypack/utils/time.dart';

import 'model.dart';
import 'viewmodel.dart';

class LogView extends StatelessWidget {
  const LogView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomView<LogModel>(
      onModelReady: (model) => model.loadModel(),
      onDoubleTapBar: (model) => model.scrollUp(),
      title: "LifeLog",
      builder: (context, model, _) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                dragStartBehavior: DragStartBehavior.down,
                controller: model.controllerScroll,
                shrinkWrap: true,
                itemCount: model.entries.length,
                itemBuilder: (context, index) {
                  final entry = model.entries[index];
                  return LogTile(
                    entry: entry,
                    trashEntry: model.trashLog,
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  color: Theme.of(context).colorScheme.secondary,
                  indent: 16,
                  endIndent: 20,
                  thickness: 1,
                  height: 1,
                ),
              ),
            ),
          ),
          InkWell(
            onDoubleTap: () => model.scrollDown(),
            child: Column(
              children: [
                Divider(
                  color: Theme.of(context).colorScheme.secondary,
                  thickness: 7,
                ),
                Divider(
                  color: Theme.of(context).colorScheme.secondary,
                  thickness: 7,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  maxLines: 5,
                  minLines: 1,
                  controller: model.controller,
                  style: const TextStyle(color: Colors.white),
                ),
              )),
              IconButton(
                onPressed: () => model.saveLog(),
                icon: const Icon(Icons.send),
                color: Theme.of(context).colorScheme.secondary,
              ),
              IconButton(
                icon: const Icon(Icons.search),
                color: model.searching
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.background,
                onPressed: () => model.toggleSearch(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LogTile extends StatelessWidget {
  final LogEntry entry;
  final void Function(int) trashEntry;

  const LogTile({
    required this.entry,
    required this.trashEntry,
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
          InkWell(
            onLongPress: () => Navigator.pushNamed(context, 'trash'),
            onTap: () => trashEntry(entry.id),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.delete),
            ),
          )
        ],
      ),
      iconColor: Theme.of(context).colorScheme.secondary,
    );
  }
}
