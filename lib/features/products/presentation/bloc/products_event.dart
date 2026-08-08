import 'package:equatable/equatable.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

final class ProductsStarted extends ProductsEvent {
  const ProductsStarted();
}

final class ProductsRefreshRequested extends ProductsEvent {
  const ProductsRefreshRequested();
}

final class ProductsNextPageRequested extends ProductsEvent {
  const ProductsNextPageRequested();
}

final class ProductsSearchQueryChanged extends ProductsEvent {
  final String query;

  const ProductsSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

final class ProductsCategorySelected extends ProductsEvent {
  /// Null (or "All") clears the filter and returns to the plain browse feed.
  final String? category;

  const ProductsCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}
