import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ecom/core/error/failures.dart';
import 'package:ecom/core/utils/result.dart';
import 'package:ecom/features/products/domain/entities/paginated_products.dart';
import 'package:ecom/features/products/domain/entities/product.dart';
import 'package:ecom/features/products/domain/repositories/products_repository.dart';
import 'package:ecom/features/products/domain/usecases/get_categories.dart';
import 'package:ecom/features/products/domain/usecases/get_products.dart';
import 'package:ecom/features/products/domain/usecases/get_products_by_category.dart';
import 'package:ecom/features/products/domain/usecases/search_products.dart';
import 'package:ecom/features/products/presentation/bloc/products_bloc.dart';
import 'package:ecom/features/products/presentation/bloc/products_event.dart';
import 'package:ecom/features/products/presentation/bloc/products_state.dart';

class _MockProductsRepository extends Mock implements ProductsRepository {}

Product _product(int id) => Product(
  id: id,
  title: 'Product $id',
  description: 'Description $id',
  category: 'shoes',
  price: 20,
  discountPercentage: 0,
  rating: 4,
  stock: 10,
  brand: 'Acme',
  thumbnail: 'https://example.com/thumb.jpg',
  images: const [],
);

void main() {
  setUpAll(() {
    registerFallbackValue(CancelToken());
  });

  late _MockProductsRepository repository;
  late ProductsBloc bloc;

  setUp(() {
    repository = _MockProductsRepository();
    bloc = ProductsBloc(
      getProducts: GetProducts(repository),
      searchProducts: SearchProducts(repository),
      getProductsByCategory: GetProductsByCategory(repository),
      getCategories: GetCategories(repository),
    );
  });

  tearDown(() => bloc.close());

  void stubGetProducts(Result<PaginatedProducts> result, {int skip = 0}) {
    when(
      () => repository.getProducts(
        limit: any(named: 'limit'),
        skip: skip,
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => result);
  }

  void stubCategories(Result<List<String>> result) {
    when(() => repository.getCategories()).thenAnswer((_) async => result);
  }

  blocTest<ProductsBloc, ProductsState>(
    'emits [loading, success] when the initial load succeeds',
    setUp: () {
      stubCategories(const Ok(['shoes', 'beauty']));
      stubGetProducts(
        Ok(
          PaginatedProducts(
            products: [_product(1), _product(2)],
            total: 2,
            skip: 0,
            limit: 20,
          ),
        ),
      );
    },
    build: () => bloc,
    act: (bloc) => bloc.add(const ProductsStarted()),
    expect: () => [
      predicate<ProductsState>((s) => s.status == ProductsStatus.loading),
      predicate<ProductsState>(
        (s) =>
            s.status == ProductsStatus.success &&
            s.products.length == 2 &&
            s.categories.length == 2 &&
            !s.isOffline,
      ),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'emits [loading, failure] when the initial load fails with no cache',
    setUp: () {
      stubCategories(const Ok(['shoes']));
      stubGetProducts(const Err(NetworkFailure()));
    },
    build: () => bloc,
    act: (bloc) => bloc.add(const ProductsStarted()),
    expect: () => [
      predicate<ProductsState>((s) => s.status == ProductsStatus.loading),
      predicate<ProductsState>(
        (s) =>
            s.status == ProductsStatus.failure &&
            s.loadFailure is NetworkFailure,
      ),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'shows cached data as offline when the initial load has no connection',
    setUp: () {
      stubCategories(const Ok(['shoes']));
      stubGetProducts(
        Ok(
          PaginatedProducts(
            products: [_product(1)],
            total: 1,
            skip: 0,
            limit: 1,
            isFromCache: true,
          ),
        ),
      );
    },
    build: () => bloc,
    act: (bloc) => bloc.add(const ProductsStarted()),
    expect: () => [
      predicate<ProductsState>((s) => s.status == ProductsStatus.loading),
      predicate<ProductsState>(
        (s) => s.status == ProductsStatus.success && s.isOffline,
      ),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'pagination appends new products, dedupes by id, and respects hasMore',
    seed: () => ProductsState(
      status: ProductsStatus.success,
      products: [_product(1), _product(2)],
      total: 4,
    ),
    setUp: () {
      // The API returning product 2 again (overlap) must not duplicate it.
      stubGetProducts(
        Ok(
          PaginatedProducts(
            products: [_product(2), _product(3), _product(4)],
            total: 4,
            skip: 2,
            limit: 20,
          ),
        ),
        skip: 2,
      );
    },
    build: () => bloc,
    act: (bloc) => bloc.add(const ProductsNextPageRequested()),
    expect: () => [
      predicate<ProductsState>((s) => s.status == ProductsStatus.loadingMore),
      predicate<ProductsState>((s) {
        final ids = s.products.map((p) => p.id).toList();
        return s.status == ProductsStatus.success &&
            ids.length == 4 &&
            ids.every((id) => [1, 2, 3, 4].contains(id)) &&
            !s.hasMore;
      }),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'ignores a next-page request when already at the end of the list',
    seed: () => ProductsState(
      status: ProductsStatus.success,
      products: [_product(1)],
      total: 1,
    ),
    build: () => bloc,
    act: (bloc) => bloc.add(const ProductsNextPageRequested()),
    expect: () => [],
    verify: (_) {
      verifyNever(
        () => repository.getProducts(
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          cancelToken: any(named: 'cancelToken'),
        ),
      );
    },
  );

  blocTest<ProductsBloc, ProductsState>(
    'a failed refresh keeps the last successful data and surfaces a '
    'transient failure instead of clearing the list',
    seed: () => ProductsState(
      status: ProductsStatus.success,
      products: [_product(1), _product(2)],
      total: 2,
    ),
    setUp: () => stubGetProducts(const Err(NetworkFailure())),
    build: () => bloc,
    act: (bloc) => bloc.add(const ProductsRefreshRequested()),
    expect: () => [
      predicate<ProductsState>((s) => s.status == ProductsStatus.refreshing),
      predicate<ProductsState>(
        (s) =>
            s.status == ProductsStatus.success &&
            s.products.length == 2 &&
            s.transientFailure is NetworkFailure,
      ),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'debounces search queries and only calls the API once for the final query',
    setUp: () {
      when(
        () => repository.searchProducts(
          query: any(named: 'query'),
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Ok(
          PaginatedProducts(products: [_product(9)], total: 1, skip: 0, limit: 20),
        ),
      );
    },
    build: () => bloc,
    act: (bloc) {
      bloc.add(const ProductsSearchQueryChanged('p'));
      bloc.add(const ProductsSearchQueryChanged('ph'));
      bloc.add(const ProductsSearchQueryChanged('phone'));
    },
    wait: const Duration(milliseconds: 500),
    expect: () => [
      predicate<ProductsState>(
        (s) => s.status == ProductsStatus.loading && s.searchQuery == 'phone',
      ),
      predicate<ProductsState>(
        (s) => s.status == ProductsStatus.success && s.products.single.id == 9,
      ),
    ],
    verify: (_) {
      verify(
        () => repository.searchProducts(
          query: 'phone',
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
      verifyNever(
        () => repository.searchProducts(
          query: 'p',
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          cancelToken: any(named: 'cancelToken'),
        ),
      );
    },
  );

  blocTest<ProductsBloc, ProductsState>(
    'selecting a category clears the active search and filters by it',
    setUp: () {
      when(
        () => repository.getProductsByCategory(
          category: 'beauty',
          limit: any(named: 'limit'),
          skip: any(named: 'skip'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Ok(
          PaginatedProducts(products: [_product(5)], total: 1, skip: 0, limit: 20),
        ),
      );
    },
    build: () => bloc,
    act: (bloc) => bloc.add(const ProductsCategorySelected('beauty')),
    expect: () => [
      predicate<ProductsState>(
        (s) =>
            s.status == ProductsStatus.loading && s.selectedCategory == 'beauty',
      ),
      predicate<ProductsState>(
        (s) =>
            s.status == ProductsStatus.success &&
            s.products.single.id == 5 &&
            s.searchQuery.isEmpty,
      ),
    ],
  );
}
