import 'package:equatable/equatable.dart';

import 'package:ecom/features/products/domain/entities/product.dart';

class FavouritesState extends Equatable {
  final List<Product> favourites;

  const FavouritesState({this.favourites = const []});

  bool contains(int productId) => favourites.any((p) => p.id == productId);

  @override
  List<Object?> get props => [favourites];
}
