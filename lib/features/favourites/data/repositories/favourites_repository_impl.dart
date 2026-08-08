import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:ecom/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:ecom/features/products/data/models/product_model.dart';
import 'package:ecom/features/products/domain/entities/product.dart';

class FavouritesRepositoryImpl implements FavouritesRepository {
  final Box<String> box;

  const FavouritesRepositoryImpl(this.box);

  @override
  List<Product> getAll() {
    return box.values.map((raw) {
      return ProductModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }).toList();
  }

  @override
  bool isFavourite(int productId) => box.containsKey(productId.toString());

  @override
  void toggle(Product product) {
    final key = product.id.toString();
    if (box.containsKey(key)) {
      box.delete(key);
    } else {
      box.put(key, jsonEncode(ProductModel.fromEntity(product).toJson()));
    }
  }
}
