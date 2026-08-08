import 'package:ecom/features/products/domain/entities/product.dart';

/// Local-only persistence — unlike the products repository this isn't
/// wrapped in a Result, since Hive reads/writes here don't have a
/// meaningful failure mode the UI needs to react to.
abstract interface class FavouritesRepository {
  List<Product> getAll();

  bool isFavourite(int productId);

  void toggle(Product product);
}
