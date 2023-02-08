import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:life_log/log/viewmodel.dart';
import 'package:mypack/ui/views/base_view.dart';

import '../log/widgets.dart';
import 'viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomView<SettingsModel>(
      onModelReady: (model) => model.loadModel(),
      title: "LifeLog - Settings",
      builder: (context, model, _) => Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Text("User: ${model.user}"),
                      LifeIconButton(
                          onTap: model.logOut,
                          color: Theme.of(context).colorScheme.secondary,
                          iconData: CupertinoIcons.lock_fill)
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Text("User: ${model.hideMode ? "******" : model.pass}"),
                      LifeIconButton(
                          onTap: model.toggleHideMode,
                          color: Theme.of(context).colorScheme.secondary,
                          iconData: CupertinoIcons.eye)
                    ],
                  ),
                  const SizedBox(height: 50),
                  DropdownButton<int>(
                    hint: const Text("Main color: "),
                    value: model.colorIndex,
                    icon: Icon(
                      CupertinoIcons.arrow_down,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    underline: Container(
                      height: 2,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onChanged: (value) =>
                        model.setMainColor(color: model.getColor(value)),
                    items: [
                      for (var i = 0; i < model.totColors; i++)
                        DropdownMenuItem<int>(
                          value: i,
                          child: Text(
                            model.niceColor(i),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 50),
                  Text("Total entries: ${model.totalEntries}"),
                  const SizedBox(height: 50),
                  Text("Total trashed: ${model.trashedEntries}"),
                ],
              ),
            ),
          ),
          InkWell(
            onDoubleTap: () => {},
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
                  if (LogModel.backMsgs.contains(model.controller.text)) {
                    Navigator.pop(context);
                  } else {
                    model.getInput();
                  }
                },
                iconData: CupertinoIcons.check_mark,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
