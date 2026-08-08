import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import 'package:ecom/core/usecase/usecase.dart';
import 'package:ecom/core/utils/result.dart';
import 'package:ecom/features/products/domain/entities/paginated_products.dart';
import 'package:ecom/features/products/domain/repositories/products_repository.dart';

class SearchProducts implements UseCase<PaginatedProducts, SearchProductsParams> {
  final ProductsRepository repository;

  const SearchProducts(this.repository);

  @override
  Future<Result<PaginatedProducts>> call(SearchProductsParams params) {
    return repository.searchProducts(
      query: params.query,
      limit: params.limit,
      skip: params.skip,
      cancelToken: params.cancelToken,
    );
  }
}

class SearchProductsParams extends Equatable {
  final String query;
  final int limit;
  final int skip;
  final CancelToken? cancelToken;

  const SearchProductsParams({
    required this.query,
    required this.limit,
    required this.skip,
    this.cancelToken,
  });

  @override
  List<Object?> get props => [query, limit, skip];
}
