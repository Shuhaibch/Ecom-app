import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ecom/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:ecom/features/favourites/presentation/bloc/favourites_state.dart';
import 'package:ecom/features/products/domain/entities/product.dart';

/// Registered as a singleton so every screen (catalogue, details,
/// favourites tab) reflects the same favourite state instantly.
class FavouritesCubit extends Cubit<FavouritesState> {
  final FavouritesRepository repository;

  FavouritesCubit(this.repository)
    : super(FavouritesState(favourites: repository.getAll()));

  bool isFavourite(int productId) => state.contains(productId);

  void toggle(Product product) {
    repository.toggle(product);
    emit(FavouritesState(favourites: repository.getAll()));
  }
}
