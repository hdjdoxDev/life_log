import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mypack/ui/shared/layout.dart';
import 'package:mypack/ui/views/base_view.dart';

import 'package:mypack/utils/time.dart';

import 'viewmodel.dart';

class LogTrashView extends StatelessWidget {
  const LogTrashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomView<LogModel>(
      onModelReady: (model) => model.loadModel(),
      builder: (context, model, _) => Scaffold(
        appBar: TappableAppBar(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.background,
            title: const Text("LifeLog",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                )),
          ),
          onDoubleTap: model.scrollUp,
          onTap: () => {},
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                  dragStartBehavior: DragStartBehavior.down,
                  controller: model.controllerScroll,
                  shrinkWrap: true,
                  itemCount: model.entries.length,
                  itemBuilder: (context, index) {
                    final entry = model.entries[index];
                    return ListTile(
                      title:
                          Text(entry.msg, style: const TextStyle(fontSize: 16)),
                      subtitle: Text(dateTimeString(entry.time),
                          style: const TextStyle(fontSize: 10)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onLongPress: () {
                              model.toggleTrash();
                              model.restoreLog(entry.id);
                            },
                            onTap: () => model.restoreLog(entry.id),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.restore),
                            ),
                          ),
                          InkWell(
                            onLongPress: () => model.toggleTrash(),
                            onTap: () => model.deleteLog(entry.id),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.delete),
                            ),
                          )
                        ],
                      ),
                      iconColor: Theme.of(context).colorScheme.secondary,
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
      ),
    );
  }
}
