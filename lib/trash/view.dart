import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/frontend.dart';

import 'viewmodel.dart';
import 'widgets.dart';

class LogTrashView extends StatelessWidget {
  const LogTrashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomView<LogTrashModel>(
      title: "LifeLog - Trash",
      initModel: (model) => model.init(),
      onDoubleTapBar: (model) => model.scrollUp(),
      body: (context, model, _) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                dragStartBehavior: DragStartBehavior.down,
                controller: model.controllerScroll,
                shrinkWrap: true,
                itemCount: model.results.length,
                itemBuilder: (context, index) => LogTrashTile(
                  entry: model.results[index],
                  restoreEntry: model.restoreLog,
                  deleteEntry: model.deleteLog,
                ),
                separatorBuilder: (context, index) => Divider(
                  color: Theme.of(context).colorScheme.primary,
                  indent: 16,
                  endIndent: 20,
                  thickness: 1,
                  height: 1,
                ),
              ),
            ),
          ),
          InkWell(
            onDoubleTap: () => model.goToBottom(),
            child: Column(
              children: [
                Divider(
                  color: Theme.of(context).colorScheme.primary,
                  thickness: 7,
                ),
                Divider(
                  color: Theme.of(context).colorScheme.primary,
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
              LifeIconButton(
                onTap: () => model.saveLog(),
                iconData: CupertinoIcons.check_mark,
                color: Theme.of(context).colorScheme.primary,
              ),
              LifeIconButton(
                iconData: CupertinoIcons.search,
                color: model.searching
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.background,
                onTap: () => model.toggleSearch(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
