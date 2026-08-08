import 'package:dio/dio.dart';

import 'package:ecom/core/error/exceptions.dart';
import 'package:ecom/core/error/failures.dart';
import 'package:ecom/core/network/network_info.dart';
import 'package:ecom/core/utils/result.dart';
import 'package:ecom/features/products/data/datasources/products_local_data_source.dart';
import 'package:ecom/features/products/data/datasources/products_remote_data_source.dart';
import 'package:ecom/features/products/domain/entities/paginated_products.dart';
import 'package:ecom/features/products/domain/entities/product.dart';
import 'package:ecom/features/products/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remote;
  final ProductsLocalDataSource local;
  final NetworkInfo networkInfo;

  const ProductsRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  @override
  Future<Result<PaginatedProducts>> getProducts({
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  }) async {
    if (!await networkInfo.isConnected) {
      return _cachedFallbackOrNetworkFailure(skip);
    }
    return _run(() async {
      final response = await remote.getProducts(
        limit: limit,
        skip: skip,
        cancelToken: cancelToken,
      );
      if (skip == 0) await local.cacheProducts(response.products);
      return response.toEntity();
    });
  }

  @override
  Future<Result<PaginatedProducts>> searchProducts({
    required String query,
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    return _run(() async {
      final response = await remote.searchProducts(
        query: query,
        limit: limit,
        skip: skip,
        cancelToken: cancelToken,
      );
      return response.toEntity();
    });
  }

  @override
  Future<Result<PaginatedProducts>> getProductsByCategory({
    required String category,
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    return _run(() async {
      final response = await remote.getProductsByCategory(
        category: category,
        limit: limit,
        skip: skip,
        cancelToken: cancelToken,
      );
      return response.toEntity();
    });
  }

  @override
  Future<Result<List<String>>> getCategories() async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    return _run(() => remote.getCategories());
  }

  @override
  Future<Result<Product>> getProductById(int id) async {
    if (!await networkInfo.isConnected) {
      return const Err(NetworkFailure());
    }
    return _run(() => remote.getProductById(id));
  }

  Result<PaginatedProducts> _cachedFallbackOrNetworkFailure(int skip) {
    if (skip == 0) {
      final cached = local.getCachedProducts();
      if (cached != null && cached.isNotEmpty) {
        return Ok(
          PaginatedProducts(
            products: cached,
            total: cached.length,
            skip: 0,
            limit: cached.length,
            isFromCache: true,
          ),
        );
      }
    }
    return const Err(NetworkFailure());
  }

  Future<Result<T>> _run<T>(Future<T> Function() request) async {
    try {
      return Ok(await request());
    } on NotFoundException catch (e) {
      return Err(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } on DioException {
      rethrow;
    }
  }
}
