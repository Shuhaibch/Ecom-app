import 'package:equatable/equatable.dart';

import 'package:ecom/features/products/domain/entities/product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get lineOriginalTotal => product.price * quantity;

  double get lineTotal => product.discountedPrice * quantity;

  double get lineDiscount => lineOriginalTotal - lineTotal;

  @override
  List<Object?> get props => [product, quantity];
}
