import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypack/locator.dart';
import 'package:mypack/ui/views/base_view.dart';

import '../login/viewmodel.dart';
import '../settings/viewmodel.dart';
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
          onTap: () => Navigator.pushNamed(context, '/settings'),
          color: Theme.of(context).colorScheme.background,
        ),
      ],
      onModelReady: (model) => model.loadModel(),
      onDoubleTapBar: (model) => model.scrollUp(),
      title: "LifeLog",
      builder: (context, model, _) => Column(
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
                            LogTile(
                              entry: model.results[i],
                              trashEntry: model.trashLog,
                              copyEntry: model.copyLog,
                            ),
                            if (i < model.results.length - 1)
                              Divider(
                                color: Theme.of(context).colorScheme.secondary,
                                indent: 16,
                                endIndent: 20,
                                thickness: 1,
                                height: 1,
                              ),
                          ],
                        ),
                    ],
                  ),
                )),
          ),
          InkWell(
            onDoubleTap: () => model.goToBottom(),
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
              LifeIconButton(
                onTap: () {
                  if (LoginModel.logOutMsgs.contains(model.controller.text)) {
                    locator.get<LoginModel>().logOut();
                  } else if (model.controller.text ==
                      SettingsModel.settingMsg) {
                    Navigator.pushNamed(context, '/settings');
                  } else {
                    model.saveLog();
                  }
                },
                iconData: CupertinoIcons.check_mark,
                color: Theme.of(context).colorScheme.secondary,
              ),
              LifeIconButton(
                color: model.searching
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.background,
                iconData: CupertinoIcons.search,
                onTap: () => model.toggleSearch(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
