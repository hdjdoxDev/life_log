import 'package:flutter/material.dart';
import 'package:mypack/ui/views/base_view.dart';

import 'settings_viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomView<SettingsModel>(
      onModelReady: (model) => model.loadModel(),
      title: "LifeLog - Settings",
      builder: (context, model, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Total entries: ${model.totalEntries}"),
            Text("Total trashed: ${model.trashedEntries}"),
            Row(
              children: [
                const Text("Main color: "),
                DropdownMenu<MaterialColor>(
                  onSelected: (value) => model.setMainColor(color: value),
                  dropdownMenuEntries: [
                    for (var color in model.colors)
                      DropdownMenuEntry<MaterialColor>(
                        value: color,
                        label: "$color",
                      )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
