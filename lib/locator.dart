import 'package:mypack/locator.dart';

import 'log/sqfl.dart';
import 'log/viewmodel.dart';

void setupLocator() {
  locator.registerLazySingletonAsync<LogSqflApi>(() => LogSqflApi.init());
  locator.registerFactory<LogModel>(() => LogModel());
}
