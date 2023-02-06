import 'package:flutter/material.dart';

import 'locator.dart';
import 'log/trash_view.dart';
import 'log/view.dart';
import 'login/view.dart';
import 'settings/view.dart';
import 'settings/viewmodel.dart';

void main() {
  setupLocator();
  runApp(const LifeLogApp());
}

class LifeLogApp extends StatelessWidget {
  const LifeLogApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Color?>(
      stream: SettingsModel.mainColorStream,
      builder: (context, stream) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LifeLog',
        theme: ThemeData(
          fontFamily: "RobotoMono",
          colorScheme: ColorScheme.dark(
            primary: Colors.white,
            secondary: stream.data ?? SettingsModel.defaultColor,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LogoView(),
          '/log': (context) => const LogView(),
          '/log/trash': (context) => const LogTrashView(),
          '/settings': (context) => const SettingsView(),
          '/login': (context) => const LoginView(),
        },
      ),
    );
  }
}

class LogoView extends StatefulWidget {
  const LogoView({super.key});

  @override
  State<LogoView> createState() => _LogoViewState();
}

class _LogoViewState extends State<LogoView> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/log');
    });
    super.initState();
  }

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
