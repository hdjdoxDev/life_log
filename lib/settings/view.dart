import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mypack/ui/views/base_view.dart';

import 'viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomView<SettingsModel>(
      onModelReady: (model) => model.loadModel(),
      title: "LifeLog - Settings",
      builder: (context, model, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("User: ${model.user}"),
            const SizedBox(height: 50),
            Text("Pass: ${model.pass}"),
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
    );
  }
}
