import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ecom/core/constants/api_constants.dart';
import 'package:ecom/core/usecase/usecase.dart';
import 'package:ecom/core/utils/bloc_transformers.dart';
import 'package:ecom/core/utils/result.dart';
import 'package:ecom/features/products/domain/entities/paginated_products.dart';
import 'package:ecom/features/products/domain/entities/product.dart';
import 'package:ecom/features/products/domain/usecases/get_categories.dart';
import 'package:ecom/features/products/domain/usecases/get_products.dart';
import 'package:ecom/features/products/domain/usecases/get_products_by_category.dart';
import 'package:ecom/features/products/domain/usecases/search_products.dart';
import 'package:ecom/features/products/presentation/bloc/products_event.dart';
import 'package:ecom/features/products/presentation/bloc/products_state.dart';

/// Thrown internally when an in-flight request is superseded by a newer
/// one. Caught by [_guarded] so the handler simply emits nothing instead
/// of surfacing a fake failure.
class _RequestSuperseded implements Exception {
  const _RequestSuperseded();
}

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProducts getProducts;
  final SearchProducts searchProducts;
  final GetProductsByCategory getProductsByCategory;
  final GetCategories getCategories;

  CancelToken? _cancelToken;

  ProductsBloc({
    required this.getProducts,
    required this.searchProducts,
    required this.getProductsByCategory,
    required this.getCategories,
  }) : super(const ProductsState()) {
    on<ProductsStarted>((e, emit) => _guarded(() => _onStarted(e, emit)));
    on<ProductsRefreshRequested>(
      (e, emit) => _guarded(() => _onRefreshRequested(e, emit)),
    );
    on<ProductsNextPageRequested>(
      (e, emit) => _guarded(() => _onNextPageRequested(e, emit)),
    );
    on<ProductsSearchQueryChanged>(
      (e, emit) => _guarded(() => _onSearchQueryChanged(e, emit)),
      transformer: debounceRestartable(const Duration(milliseconds: 400)),
    );
    on<ProductsCategorySelected>(
      (e, emit) => _guarded(() => _onCategorySelected(e, emit)),
      transformer: restartable(),
    );
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel();
    return super.close();
  }

  Future<void> _guarded(Future<void> Function() action) async {
    try {
      await action();
    } on _RequestSuperseded {
      // A newer request already took over; nothing to do.
    }
  }

  Future<void> _onStarted(
    ProductsStarted event,
    Emitter<ProductsState> emit,
  ) async {
    if (state.status != ProductsStatus.initial) return;
    emit(
      state.copyWith(status: ProductsStatus.loading, clearLoadFailure: true),
    );

    final categoriesResult = await getCategories(const NoParams());
    final categories = categoriesResult.when(
      ok: (c) => c,
      err: (_) => const <String>[],
    );

    await _fetchFirstPage(emit, categories: categories);
  }

  Future<void> _onRefreshRequested(
    ProductsRefreshRequested event,
    Emitter<ProductsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProductsStatus.refreshing,
        clearTransientFailure: true,
      ),
    );
    await _fetchFirstPage(emit, categories: state.categories, isRefresh: true);
  }

  Future<void> _onNextPageRequested(
    ProductsNextPageRequested event,
    Emitter<ProductsState> emit,
  ) async {
    if (state.status != ProductsStatus.success || !state.hasMore) return;

    emit(
      state.copyWith(
        status: ProductsStatus.loadingMore,
        clearTransientFailure: true,
      ),
    );

    final result = await _fetchPage(skip: state.products.length);
    result.when(
      ok: (page) => emit(
        state.copyWith(
          status: ProductsStatus.success,
          products: _mergeUnique(state.products, page.products),
          total: page.total,
        ),
      ),
      err: (failure) => emit(
        state.copyWith(
          status: ProductsStatus.success,
          transientFailure: failure,
        ),
      ),
    );
  }

  Future<void> _onSearchQueryChanged(
    ProductsSearchQueryChanged event,
    Emitter<ProductsState> emit,
  ) async {
    final query = event.query.trim();
    if (query == state.searchQuery) return;

    emit(
      state.copyWith(
        status: ProductsStatus.loading,
        searchQuery: query,
        clearSelectedCategory: true,
        clearLoadFailure: true,
      ),
    );

    if (query.isEmpty) {
      await _fetchFirstPage(emit, categories: state.categories);
      return;
    }

    final result = await _fetchPage(skip: 0, query: query);
    result.when(
      ok: (page) => emit(
        state.copyWith(
          status: ProductsStatus.success,
          products: page.products,
          total: page.total,
          isOffline: false,
        ),
      ),
      err: (failure) => emit(
        state.copyWith(status: ProductsStatus.failure, loadFailure: failure),
      ),
    );
  }

  Future<void> _onCategorySelected(
    ProductsCategorySelected event,
    Emitter<ProductsState> emit,
  ) async {
    final category = (event.category == null || event.category!.isEmpty)
        ? null
        : event.category;
    if (category == state.selectedCategory) return;

    emit(
      state.copyWith(
        status: ProductsStatus.loading,
        selectedCategory: category,
        clearSelectedCategory: category == null,
        searchQuery: '',
        clearLoadFailure: true,
      ),
    );

    await _fetchFirstPage(emit, categories: state.categories);
  }

  Future<void> _fetchFirstPage(
    Emitter<ProductsState> emit, {
    required List<String> categories,
    bool isRefresh = false,
  }) async {
    final result = await _fetchPage(skip: 0);
    result.when(
      ok: (page) => emit(
        state.copyWith(
          status: ProductsStatus.success,
          products: page.products,
          total: page.total,
          categories: categories,
          isOffline: page.isFromCache,
          clearTransientFailure: true,
        ),
      ),
      err: (failure) {
        if (isRefresh && state.products.isNotEmpty) {
          emit(
            state.copyWith(
              status: ProductsStatus.success,
              transientFailure: failure,
              categories: categories,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: ProductsStatus.failure,
              loadFailure: failure,
              categories: categories,
            ),
          );
        }
      },
    );
  }

  Future<Result<PaginatedProducts>> _fetchPage({
    required int skip,
    String? query,
  }) async {
    _cancelToken?.cancel();
    final token = CancelToken();
    _cancelToken = token;

    try {
      final effectiveQuery = query ?? (state.isSearching ? state.searchQuery : null);
      if (effectiveQuery != null && effectiveQuery.isNotEmpty) {
        return await searchProducts(
          SearchProductsParams(
            query: effectiveQuery,
            limit: ApiConstants.defaultPageLimit,
            skip: skip,
            cancelToken: token,
          ),
        );
      }
      if (state.selectedCategory != null) {
        return await getProductsByCategory(
          GetProductsByCategoryParams(
            category: state.selectedCategory!,
            limit: ApiConstants.defaultPageLimit,
            skip: skip,
            cancelToken: token,
          ),
        );
      }
      return await getProducts(
        GetProductsParams(
          limit: ApiConstants.defaultPageLimit,
          skip: skip,
          cancelToken: token,
        ),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) throw const _RequestSuperseded();
      rethrow;
    }
  }

  List<Product> _mergeUnique(List<Product> existing, List<Product> incoming) {
    final seenIds = existing.map((p) => p.id).toSet();
    final deduped = incoming.where((p) => seenIds.add(p.id));
    return [...existing, ...deduped];
  }
}
