import 'package:flutter/material.dart';
import 'package:frontend/frontend.dart';
import 'package:life_log/main.dart';

import 'viewmodel.dart';

class ShareView extends StatelessWidget {
  const ShareView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomView<ShareModel>(
      initModel: (model) => model.init(),
      title: "LifeLog - Settings",
      body: (context, model, _) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: model.ipController,
              decoration: const InputDecoration(labelText: "IP", hintText: ""),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => model.startSink(context),
              child: const Text("Connect"),
            ),
            const SizedBox(height: 20),
            Text(model.connection),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: model.deleteSyncData,
              child: const Text("Reset"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    LifeLogRoutes.home, (route) => false),
                child: const Text("Lock"))
          ],
        ),
      ),
    );
  }
}
