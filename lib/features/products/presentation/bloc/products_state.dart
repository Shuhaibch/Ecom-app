import 'package:equatable/equatable.dart';

import 'package:ecom/core/error/failures.dart';
import 'package:ecom/features/products/domain/entities/product.dart';

enum ProductsStatus { initial, loading, loadingMore, refreshing, success, failure }

class ProductsState extends Equatable {
  final ProductsStatus status;
  final List<Product> products;
  final int total;
  final List<String> categories;
  final String? selectedCategory;
  final String searchQuery;
  final bool isOffline;

  /// Set on a failed refresh/pagination so the UI can show a transient
  /// error (snackbar) while [products] keeps showing the last good data.
  final Failure? transientFailure;

  /// Set when the *first* load of a given query/category/browse fails
  /// outright, i.e. there is no data at all to fall back to.
  final Failure? loadFailure;

  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.total = 0,
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.isOffline = false,
    this.transientFailure,
    this.loadFailure,
  });

  bool get hasMore => products.length < total;

  bool get isEmptyResult =>
      status == ProductsStatus.success && products.isEmpty;

  bool get isSearching => searchQuery.isNotEmpty;

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    int? total,
    List<String>? categories,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    String? searchQuery,
    bool? isOffline,
    Failure? transientFailure,
    bool clearTransientFailure = false,
    Failure? loadFailure,
    bool clearLoadFailure = false,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      total: total ?? this.total,
      categories: categories ?? this.categories,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      isOffline: isOffline ?? this.isOffline,
      transientFailure: clearTransientFailure
          ? null
          : (transientFailure ?? this.transientFailure),
      loadFailure: clearLoadFailure ? null : (loadFailure ?? this.loadFailure),
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    total,
    categories,
    selectedCategory,
    searchQuery,
    isOffline,
    transientFailure,
    loadFailure,
  ];
}
