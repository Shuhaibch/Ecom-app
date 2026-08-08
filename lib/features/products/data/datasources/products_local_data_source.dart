import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:ecom/features/products/data/models/product_model.dart';

abstract interface class ProductsLocalDataSource {
  /// Products from the last successful unfiltered browse fetch, or null
  /// if nothing has been cached yet.
  List<ProductModel>? getCachedProducts();

  Future<void> cacheProducts(List<ProductModel> products);
}

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  static const _cacheKey = 'last_products';

  final Box<String> box;

  const ProductsLocalDataSourceImpl(this.box);

  @override
  List<ProductModel>? getCachedProducts() {
    final raw = box.get(_cacheKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! List) return null;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final encoded = jsonEncode(products.map((p) => p.toJson()).toList());
    await box.put(_cacheKey, encoded);
  }
}
