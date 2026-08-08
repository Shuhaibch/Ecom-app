import 'package:dio/dio.dart';

import 'package:ecom/core/utils/result.dart';
import 'package:ecom/features/products/domain/entities/paginated_products.dart';
import 'package:ecom/features/products/domain/entities/product.dart';

abstract interface class ProductsRepository {
  Future<Result<PaginatedProducts>> getProducts({
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  });

  Future<Result<PaginatedProducts>> searchProducts({
    required String query,
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  });

  Future<Result<PaginatedProducts>> getProductsByCategory({
    required String category,
    required int limit,
    required int skip,
    CancelToken? cancelToken,
  });

  Future<Result<List<String>>> getCategories();

  Future<Result<Product>> getProductById(int id);
}
