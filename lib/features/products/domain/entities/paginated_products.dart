import 'package:equatable/equatable.dart';

import 'package:ecom/features/products/domain/entities/product.dart';

class PaginatedProducts extends Equatable {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;
  final bool isFromCache;

  const PaginatedProducts({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
    this.isFromCache = false,
  });

  bool get hasMore => skip + products.length < total;

  @override
  List<Object?> get props => [products, total, skip, limit, isFromCache];
}
