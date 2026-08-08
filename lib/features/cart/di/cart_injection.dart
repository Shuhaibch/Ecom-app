import 'package:ecom/core/constants/hive_constants.dart';
import 'package:ecom/core/di/injection_container.dart';
import 'package:ecom/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ecom/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_cubit.dart';

void initCartFeature() {
  sl
    ..registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(sl(instanceName: HiveConstants.cartBox)),
    )
    ..registerLazySingleton(() => CartCubit(sl()));
}
