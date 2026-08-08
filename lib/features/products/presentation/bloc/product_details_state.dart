import 'package:equatable/equatable.dart';

import 'package:ecom/core/error/failures.dart';
import 'package:ecom/features/products/domain/entities/product.dart';

enum ProductDetailsStatus { loading, success, failure }

class ProductDetailsState extends Equatable {
  final ProductDetailsStatus status;
  final Product? product;
  final Failure? failure;

  const ProductDetailsState({
    this.status = ProductDetailsStatus.loading,
    this.product,
    this.failure,
  });

  @override
  List<Object?> get props => [status, product, failure];
}
