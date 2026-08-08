import 'package:equatable/equatable.dart';

import 'package:ecom/core/usecase/usecase.dart';
import 'package:ecom/core/utils/result.dart';
import 'package:ecom/features/products/domain/entities/product.dart';
import 'package:ecom/features/products/domain/repositories/products_repository.dart';

class GetProductById implements UseCase<Product, GetProductByIdParams> {
  final ProductsRepository repository;

  const GetProductById(this.repository);

  @override
  Future<Result<Product>> call(GetProductByIdParams params) {
    return repository.getProductById(params.id);
  }
}

class GetProductByIdParams extends Equatable {
  final int id;

  const GetProductByIdParams(this.id);

  @override
  List<Object?> get props => [id];
}
