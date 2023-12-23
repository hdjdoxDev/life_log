import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/frontend.dart';
import 'package:life_log/main.dart';
import 'package:utils/stringify.dart';
import 'package:utils/time.dart';

import '../widgets/category_picker.dart';
import '../widgets/life_icon_button.dart';
import '../widgets/log_tile.dart';
import 'viewmodel.dart';

class LogView extends StatelessWidget {
  const LogView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomView<LogModel>(
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
      initModel: (model) => model.init(),
      onDoubleTapBar: (model) => model.scrollUp(),
      onLongPressBar: (model) =>
          Navigator.pushReplacementNamed(context, LifeLogRoutes.home),
      title: "LifeLog - ${weekDaysShort(now.weekday)} ${now.day}",
      titleColor: (model) => model.categorySelection.color,
      body: (context, model, _) => Column(
        children: [
          Container(height: 8, color: model.categorySelection.color),
          Expanded(
            child: SingleChildScrollView(
              controller: model.controllerScroll,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < model.results.length; i++) ...[
                    LogTile(
                      entry: model.results[i],
                      trashEntry: model.trashLog,
                      copyEntry: model.handleLogSwipe,
                      selectLog: model.handleLogLongPress,
                      selected: model.logSelection == model.results[i].id,
                    ),
                    if (i < model.results.length - 1)
                      Divider(
                        color: model.categorySelection.color,
                        indent: 16,
                        endIndent: 16,
                        thickness: 2,
                        height: 1,
                      ),
                    if (i < model.results.length - 1 &&
                        model.results[i].time.day !=
                            model.results[i + 1].time.day) ...[
                      const SizedBox(height: 4),
                      Divider(
                        color: model.categorySelection.color,
                        indent: 16,
                        endIndent: 16,
                        thickness: 2,
                        height: 1,
                      ),
                    ]
                  ],
                ],
              ),
            ),
          ),
          CategoryPicker(
            onSelection: model.handleCategoryPick,
            selected: model.categorySelection,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: model.focusNode,
                    maxLines: 5,
                    minLines: 1,
                    controller: model.controller,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                LifeIconButton(
                  onTap: model.handleSave,
                  onLongPress: model.handleSaveLongPress,
                  iconData: CupertinoIcons.check_mark,
                  color: model.categorySelection.color,
                ),
                const SizedBox(width: 8),
                LifeIconButton(
                  color: model.searchingMode
                      ? model.categorySelection.color
                      : Theme.of(context).colorScheme.background,
                  iconData: CupertinoIcons.search,
                  onTap: () => model.handleSearch(),
                ),
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
