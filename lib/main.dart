import 'package:flutter/material.dart';
import 'package:mypack/ui/views/base_view.dart';

import 'locator.dart';
import 'log/settings_view.dart';
import 'log/settings_viewmodel.dart';
import 'log/trash_view.dart';
import 'log/view.dart';

void main() {
  setupLocator();
  runApp(const LifeLogApp());
}

class LifeLogApp extends StatelessWidget {
  const LifeLogApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeLog',
      theme: ThemeData(
        fontFamily: "RobotoMono",
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: SettingsModel.defaultColor,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LogoView(),
        '/log': (context) => const LogView(),
        '/log/trash': (context) => const LogTrashView(),
        '/settings': (context) => const SettingsView(),
      },
    );
  }
}

class LogoView extends StatelessWidget {
  const LogoView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<SettingsModel>(
      onModelReady: (model) {
        model.loadModel().then((_) => model.addListener(() {
              Theme.of(context).copyWith(
                  colorScheme: ColorScheme.dark(
                primary: Colors.white,
                secondary: model.mainColor,
              ));
            }));
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/log');
        });
      },
      builder: (context, model, child) => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "LifeLog",
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
