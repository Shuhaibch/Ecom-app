import 'package:equatable/equatable.dart';

import 'package:ecom/features/cart/domain/entities/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.lineOriginalTotal);

  double get discount => items.fold(0, (sum, item) => sum + item.lineDiscount);

  double get total => subtotal - discount;

  int quantityOf(int productId) {
    for (final item in items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  @override
  List<Object?> get props => [items];
}
