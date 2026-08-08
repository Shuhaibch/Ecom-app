import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import 'package:ecom/core/usecase/usecase.dart';
import 'package:ecom/core/utils/result.dart';
import 'package:ecom/features/products/domain/entities/paginated_products.dart';
import 'package:ecom/features/products/domain/repositories/products_repository.dart';

class GetProductsByCategory
    implements UseCase<PaginatedProducts, GetProductsByCategoryParams> {
  final ProductsRepository repository;

  const GetProductsByCategory(this.repository);

  @override
  Future<Result<PaginatedProducts>> call(GetProductsByCategoryParams params) {
    return repository.getProductsByCategory(
      category: params.category,
      limit: params.limit,
      skip: params.skip,
      cancelToken: params.cancelToken,
    );
  }
}

class GetProductsByCategoryParams extends Equatable {
  final String category;
  final int limit;
  final int skip;
  final CancelToken? cancelToken;

  const GetProductsByCategoryParams({
    required this.category,
    required this.limit,
    required this.skip,
    this.cancelToken,
  });

  @override
  List<Object?> get props => [category, limit, skip];
}
