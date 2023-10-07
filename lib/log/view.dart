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
                              color: model.results[i].category.color,
                              indent: 16,
                              endIndent: 20,
                              thickness: 1,
                              height: 1,
                            ),
                            LogTile(
                              entry: model.results[i],
                              trashEntry: model.trashLog,
                              copyEntry: model.copyLog,
                              color: model.category.color,
                              editCategory: model.editCategory,
                              selected:
                                  model.categoryIndex == model.results[i].id,
                            ),
                          ],
                        ),
                    ],
                  ),
                )),
          ),
          CategoryPicker(
            onSelection: (category) => model.setCategory(category),
            selected: model.category,
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
                  onSubmitted: (text) => model.saveLog(),
                ),
              )),
              LifeIconButton(
                onTap: () {
                  model.saveLog();
                },
                iconData: CupertinoIcons.check_mark,
                color: model.category.color,
              ),
              LifeIconButton(
                color: model.searching
                    ? model.category.color
                    : Theme.of(context).colorScheme.background,
                iconData: CupertinoIcons.search,
                onTap: () => model.toggleSearch(),
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
