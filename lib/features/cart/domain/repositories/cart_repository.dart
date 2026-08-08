import 'package:ecom/features/cart/domain/entities/cart_item.dart';
import 'package:ecom/features/products/domain/entities/product.dart';

/// Local-only persistence — same rationale as FavouritesRepository:
/// no Result wrapping, since Hive reads/writes here don't have a
/// meaningful failure mode the UI needs to react to.
abstract interface class CartRepository {
  List<CartItem> getAll();

  /// Setting quantity to 0 or below removes the item entirely.
  void setQuantity(Product product, int quantity);
}
