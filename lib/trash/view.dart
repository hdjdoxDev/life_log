import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/frontend.dart';

import '../main.dart';
import '../widgets/life_icon_button.dart';
import '../widgets/log_trash_tile.dart';
import 'viewmodel.dart';

class LogTrashView extends StatelessWidget {
  final Color viewColor = Colors.grey;

  const LogTrashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomView<LogTrashModel>(
      title: "LifeLog - Trash",
      titleColor: (_) => viewColor,
      initModel: (model) => model.init(),
      onDoubleTapBar: (model) => model.scrollUp(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: LifeIconButton(
            iconData: CupertinoIcons.settings,
            onTap: () => Navigator.pushNamed(context, LifeLogRoutes.settings),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
      body: (context, model, _) => Column(
        children: [
          Container(height: 8, color: viewColor),
          Expanded(
            child: SingleChildScrollView(
              controller: model.controllerScroll,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < model.results.length; i++) ...[
                    LogTrashTile(
                      entry: model.results[i],
                      restoreEntry: model.restoreLog,
                      color: viewColor,
                    ),
                    if (i < model.results.length - 1)
                      Divider(
                        color: viewColor,
                        indent: 16,
                        endIndent: 16,
                        thickness: 1,
                        height: 1,
                      ),
                  ],
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => model.goToBottom(),
            child: Column(
                children: [
              viewColor,
              Theme.of(context).colorScheme.background,
              viewColor,
            ].map((e) => Container(color: e, height: 8)).toList()),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      maxLines: 5,
                      minLines: 1,
                      controller: model.controller,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                LifeIconButton(
                  iconData: CupertinoIcons.search,
                  color: model.searchingMode
                      ? viewColor
                      : Theme.of(context).colorScheme.background,
                  onTap: () => model.handleSearch(),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
