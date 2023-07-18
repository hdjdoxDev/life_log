import 'package:frontend/locator.dart';

import 'log/sqfl.dart';
import 'log/trash_viewmodel.dart';
import 'log/viewmodel.dart';
import 'settings/sqfl.dart';
import 'settings/viewmodel.dart';

void setupLocator() {
  locator.registerLazySingletonAsync<LogSqflApi>(() => LogSqflApi.init());
  locator.registerLazySingletonAsync<SettingsSqflApi>(
      () => SettingsSqflApi.init());

  locator.registerFactory<LogModel>(() => LogModel());
  locator.registerFactory<LogTrashModel>(() => LogTrashModel());
  locator.registerFactory<SettingsModel>(() => SettingsModel());
}
