import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import 'package:ecom/core/usecase/usecase.dart';
import 'package:ecom/core/utils/result.dart';
import 'package:ecom/features/products/domain/entities/paginated_products.dart';
import 'package:ecom/features/products/domain/repositories/products_repository.dart';

class GetProducts implements UseCase<PaginatedProducts, GetProductsParams> {
  final ProductsRepository repository;

  const GetProducts(this.repository);

  @override
  Future<Result<PaginatedProducts>> call(GetProductsParams params) {
    return repository.getProducts(
      limit: params.limit,
      skip: params.skip,
      cancelToken: params.cancelToken,
    );
  }
}

class GetProductsParams extends Equatable {
  final int limit;
  final int skip;
  final CancelToken? cancelToken;

  const GetProductsParams({
    required this.limit,
    required this.skip,
    this.cancelToken,
  });

  @override
  List<Object?> get props => [limit, skip];
}
