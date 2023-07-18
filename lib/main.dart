import 'package:flutter/material.dart';

import 'locator.dart';
import 'log/trash_view.dart';
import 'log/view.dart';
import 'logo_view.dart';
import 'settings/view.dart';
import 'settings/viewmodel.dart';

void main() {
  setupLocator();
  runApp(const LifeLogApp());
}

class LifeLogApp extends StatelessWidget {
  const LifeLogApp({super.key});

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
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const LogoView(),
      ),
      initialRoute: LifeLogRoutes.initialRoute,
      routes: LifeLogRoutes.routes,
    );
  }
}

class LifeLogRoutes {
  static const String home = '/';
  static const String initialRoute = home;

  // other views - sn. localRoute
  static const String log = '${home}log'; // sn. localRoute
  static const String settings = '${home}settings'; // sn. localRoute
  static const String trash = '${home}trash'; // sn. localRoute

  // subsections - sn. subRouteHome

  static Map<String, Widget Function(BuildContext)> get routes => {
        home: (context) => const LogoView(),
        log: (context) => const LogView(),
        settings: (context) => const SettingsView(),
        trash: (context) => const LogTrashView(),
        // local routes - sn. newRoute

        // subroutes - ...SubRoutes.routes,
      };

  static get pathsFromHome => [
        // subRoutes home
      ];
}
