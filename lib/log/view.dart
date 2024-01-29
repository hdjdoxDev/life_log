import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/frontend.dart';
import 'package:utils/stringify.dart';
import 'package:utils/time.dart';

import '../main.dart';
import '../widgets/category_picker.dart';
import '../widgets/life_icon_button.dart';
import '../widgets/log_tile.dart';
import 'viewmodel.dart';

class LogView extends StatelessWidget {
  const LogView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomView<LogModel>(
      title: "LifeLog - ${weekDaysShort(now.weekday)} ${now.day}",
      titleColor: (model) => model.categorySelection.color,
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 8,
            color: model.categorySelection.color,
          ),
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
                        thickness: 1,
                        height: 1,
                      ),
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
                LifeIconButton(
                  onTap: model.handleSave,
                  onLongPress: model.handleSaveLongPress,
                  iconData: CupertinoIcons.check_mark,
                  color: model.categorySelection.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      focusNode: model.focusNode,
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
                      ? model.categorySelection.color
                      : Theme.of(context).colorScheme.background,
                  onTap: () => model.handleSearch(),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
