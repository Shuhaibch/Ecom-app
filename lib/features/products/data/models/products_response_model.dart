import 'package:ecom/features/products/data/models/product_model.dart';
import 'package:ecom/features/products/domain/entities/paginated_products.dart';

class ProductsResponseModel {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  const ProductsResponseModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'];
    final products = rawProducts is List
        ? rawProducts
              .whereType<Map<String, dynamic>>()
              .map(ProductModel.fromJson)
              .toList()
        : <ProductModel>[];

    return ProductsResponseModel(
      products: products,
      total: (json['total'] as num?)?.toInt() ?? products.length,
      skip: (json['skip'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? products.length,
    );
  }

  PaginatedProducts toEntity() => PaginatedProducts(
    products: products,
    total: total,
    skip: skip,
    limit: limit,
  );
}
