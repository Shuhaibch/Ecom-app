import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ecom/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecom/features/products/domain/entities/product.dart';

/// Registered as a singleton so every screen (catalogue, details, cart
/// tab) reflects the same cart state instantly.
class CartCubit extends Cubit<CartState> {
  final CartRepository repository;

  CartCubit(this.repository) : super(CartState(items: repository.getAll()));

  int quantityOf(int productId) => state.quantityOf(productId);

  void increment(Product product) {
    final current = state.quantityOf(product.id);
    if (current >= product.stock) return;
    HapticFeedback.lightImpact();
    repository.setQuantity(product, current + 1);
    _refresh();
  }

  void decrement(Product product) {
    final current = state.quantityOf(product.id);
    if (current <= 0) return;
    HapticFeedback.selectionClick();
    repository.setQuantity(product, current - 1);
    _refresh();
  }

  void removeItem(Product product) {
    HapticFeedback.mediumImpact();
    repository.setQuantity(product, 0);
    _refresh();
  }

  /// Clears every item, e.g. after an order is confirmed.
  void checkout() {
    HapticFeedback.heavyImpact();
    repository.clear();
    _refresh();
  }

  void _refresh() => emit(CartState(items: repository.getAll()));
}
