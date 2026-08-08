import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:ecom/features/cart/domain/entities/cart_item.dart';
import 'package:ecom/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecom/features/products/data/models/product_model.dart';
import 'package:ecom/features/products/domain/entities/product.dart';

class CartRepositoryImpl implements CartRepository {
  final Box<String> box;

  const CartRepositoryImpl(this.box);

  @override
  List<CartItem> getAll() {
    return box.values.map((raw) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final product = ProductModel.fromJson(
        json['product'] as Map<String, dynamic>,
      );
      final quantity = (json['quantity'] as num).toInt();
      return CartItem(product: product, quantity: quantity);
    }).toList();
  }

  @override
  void setQuantity(Product product, int quantity) {
    final key = product.id.toString();
    if (quantity <= 0) {
      box.delete(key);
      return;
    }
    box.put(
      key,
      jsonEncode({
        'product': ProductModel.fromEntity(product).toJson(),
        'quantity': quantity,
      }),
    );
  }
}
