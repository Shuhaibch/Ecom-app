import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ecom/core/constants/hive_constants.dart';
import 'package:ecom/core/network/dio_client.dart';
import 'package:ecom/core/network/network_info.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  await _initHive();
  _initCore();
}

Future<void> _initHive() async {
  await Hive.initFlutter();

  final boxes = await Future.wait([
    Hive.openBox<String>(HiveConstants.favouritesBox),
    Hive.openBox<String>(HiveConstants.cartBox),
    Hive.openBox<String>(HiveConstants.productsCacheBox),
  ]);

  sl.registerLazySingleton<Box<String>>(
    () => boxes[0],
    instanceName: HiveConstants.favouritesBox,
  );
  sl.registerLazySingleton<Box<String>>(
    () => boxes[1],
    instanceName: HiveConstants.cartBox,
  );
  sl.registerLazySingleton<Box<String>>(
    () => boxes[2],
    instanceName: HiveConstants.productsCacheBox,
  );
}

void _initCore() {
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => DioClient());
}
