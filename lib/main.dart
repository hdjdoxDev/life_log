import 'package:flutter/material.dart';

import 'locator.dart';
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
            secondary: Colors.yellow,
          ),
        ),
        initialRoute: '/log',
        routes: {
          '/log': (context) => const LogView(),
          '/log/trash':(context) => const LogTrashView(),
        });
  }
}

class LogoView extends StatelessWidget {
  const LogoView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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
    );
  }
}
