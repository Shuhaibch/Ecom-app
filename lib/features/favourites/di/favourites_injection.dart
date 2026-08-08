import 'package:ecom/core/constants/hive_constants.dart';
import 'package:ecom/core/di/injection_container.dart';
import 'package:ecom/features/favourites/data/repositories/favourites_repository_impl.dart';
import 'package:ecom/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:ecom/features/favourites/presentation/bloc/favourites_cubit.dart';

void initFavouritesFeature() {
  sl
    ..registerLazySingleton<FavouritesRepository>(
      () => FavouritesRepositoryImpl(
        sl(instanceName: HiveConstants.favouritesBox),
      ),
    )
    ..registerLazySingleton(() => FavouritesCubit(sl()));
}
