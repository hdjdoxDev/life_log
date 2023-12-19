import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/frontend.dart';
import 'package:life_log/main.dart';

import 'viewmodel.dart';
import 'widgets.dart';

class LogView extends StatelessWidget {
  const LogView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomView<LogModel>(
      actions: [
        LifeIconButton(
          iconData: CupertinoIcons.settings,
          onTap: () => Navigator.pushNamed(context, LifeLogRoutes.settings),
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
      initModel: (model) => model.init(),
      onDoubleTapBar: (model) => model.scrollUp(),
      onLongPressBar: (model) =>
          Navigator.pushReplacementNamed(context, LifeLogRoutes.home),
      title: "LifeLog",
      body: (context, model, _) => Column(
        children: [
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  controller: model.controllerScroll,
                  child: Column(
                    children: [
                      for (var i = 0; i < model.results.length; i++)
                        Column(
                          children: [
                            Divider(
                              color: model.categorySelection.color,
                              indent: 16,
                              endIndent: 20,
                              thickness: 1,
                              height: 1,
                            ),
                            LogTile(
                              entry: model.results[i],
                              trashEntry: model.trashLog,
                              copyEntry: model.handleLogSwipe,
                              selectLog: model.handleLogLongPress,
                              selected:
                                  model.logSelection == model.results[i].id,
                            ),
                          ],
                        ),
                    ],
                  ),
                )),
          ),
          CategoryPicker(
            onSelection: model.handleCategoryPick,
            selected: model.categorySelection,
          ),
          Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  focusNode: model.focusNode,
                  maxLines: 5,
                  minLines: 1,
                  controller: model.controller,
                  style: const TextStyle(color: Colors.white),
                ),
              )),
              LifeIconButton(
                onTap: model.handleSave,
                onLongPress: model.handleSaveLongPress,
                iconData: CupertinoIcons.check_mark,
                color: model.categorySelection.color,
              ),
              LifeIconButton(
                color: model.searchingMode
                    ? model.categorySelection.color
                    : Theme.of(context).colorScheme.background,
                iconData: CupertinoIcons.search,
                onTap: () => model.handleSearch(),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
