import 'package:ecom/core/constants/hive_constants.dart';
import 'package:ecom/core/di/injection_container.dart';
import 'package:ecom/core/network/dio_client.dart';
import 'package:ecom/features/products/data/datasources/products_local_data_source.dart';
import 'package:ecom/features/products/data/datasources/products_remote_data_source.dart';
import 'package:ecom/features/products/data/repositories/products_repository_impl.dart';
import 'package:ecom/features/products/domain/repositories/products_repository.dart';
import 'package:ecom/features/products/domain/usecases/get_categories.dart';
import 'package:ecom/features/products/domain/usecases/get_product_by_id.dart';
import 'package:ecom/features/products/domain/usecases/get_products.dart';
import 'package:ecom/features/products/domain/usecases/get_products_by_category.dart';
import 'package:ecom/features/products/domain/usecases/search_products.dart';
import 'package:ecom/features/products/presentation/bloc/product_details_cubit.dart';
import 'package:ecom/features/products/presentation/bloc/products_bloc.dart';

void initProductsFeature() {
  sl
    ..registerLazySingleton<ProductsRemoteDataSource>(
      () => ProductsRemoteDataSourceImpl(sl<DioClient>().dio),
    )
    ..registerLazySingleton<ProductsLocalDataSource>(
      () => ProductsLocalDataSourceImpl(
        sl(instanceName: HiveConstants.productsCacheBox),
      ),
    )
    ..registerLazySingleton<ProductsRepository>(
      () => ProductsRepositoryImpl(
        remote: sl(),
        local: sl(),
        networkInfo: sl(),
      ),
    )
    ..registerLazySingleton(() => GetProducts(sl()))
    ..registerLazySingleton(() => SearchProducts(sl()))
    ..registerLazySingleton(() => GetProductsByCategory(sl()))
    ..registerLazySingleton(() => GetCategories(sl()))
    ..registerLazySingleton(() => GetProductById(sl()))
    ..registerFactory(
      () => ProductsBloc(
        getProducts: sl(),
        searchProducts: sl(),
        getProductsByCategory: sl(),
        getCategories: sl(),
      ),
    )
    ..registerFactory(() => ProductDetailsCubit(sl()));
}
