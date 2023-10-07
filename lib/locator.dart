import 'package:frontend/locator.dart';

import 'data/sqfl.dart';
import 'trash/viewmodel.dart';
import 'log/viewmodel.dart';
import 'share/viewmodel.dart';

void setupLocator() {
  locator.registerLazySingletonAsync<ILogApi>(() => LogSqflApi.init());

  locator.registerFactory<LogModel>(() => LogModel());
  locator.registerFactory<LogTrashModel>(() => LogTrashModel());
  locator.registerFactory<ShareModel>(() => ShareModel());
}
