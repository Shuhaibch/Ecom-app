import 'package:dio/dio.dart';

import 'package:ecom/core/constants/api_constants.dart';
import 'package:ecom/core/error/exceptions.dart';
import 'package:ecom/features/products/data/models/product_model.dart';
import 'package:ecom/features/products/data/models/products_response_model.dart';

abstract interface class ProductsRemoteDataSource {
  Future<ProductsResponseModel> getProducts({
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  });

  Future<ProductsResponseModel> searchProducts({
    required String query,
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  });

  Future<ProductsResponseModel> getProductsByCategory({
    required String category,
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  });

  Future<List<String>> getCategories();

  Future<ProductModel> getProductById(int id);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final Dio dio;

  const ProductsRemoteDataSourceImpl(this.dio);

  @override
  Future<ProductsResponseModel> getProducts({
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  }) async {
    final response = await _get(
      ApiConstants.products,
      queryParameters: {'limit': limit, 'skip': skip},
      cancelToken: cancelToken,
    );
    return ProductsResponseModel.fromJson(response);
  }

  @override
  Future<ProductsResponseModel> searchProducts({
    required String query,
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  }) async {
    final response = await _get(
      ApiConstants.productSearch,
      queryParameters: {'q': query, 'limit': limit, 'skip': skip},
      cancelToken: cancelToken,
    );
    return ProductsResponseModel.fromJson(response);
  }

  @override
  Future<ProductsResponseModel> getProductsByCategory({
    required String category,
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  }) async {
    final response = await _get(
      '${ApiConstants.products}/category/$category',
      queryParameters: {'limit': limit, 'skip': skip},
      cancelToken: cancelToken,
    );
    return ProductsResponseModel.fromJson(response);
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await _get(ApiConstants.categoryList);
    if (response is! List) return const [];
    return response.map((e) => e.toString()).toList();
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await _get('${ApiConstants.products}/$id');
    return ProductModel.fromJson(response);
  }

  Future<dynamic> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      // Cancellation isn't a real failure — a newer request superseded
      // this one. Rethrow as-is so callers can distinguish and ignore it.
      if (CancelToken.isCancel(e)) rethrow;
      if (e.response?.statusCode == 404) {
        throw const NotFoundException();
      }
      throw ServerException(e.message ?? 'Server error');
    }
  }
}
