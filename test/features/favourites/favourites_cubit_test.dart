import 'package:flutter_test/flutter_test.dart';

import 'package:ecom/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:ecom/features/favourites/presentation/bloc/favourites_cubit.dart';
import 'package:ecom/features/products/domain/entities/product.dart';

class _InMemoryFavouritesRepository implements FavouritesRepository {
  final Map<int, Product> _store = {};

  @override
  List<Product> getAll() => _store.values.toList();

  @override
  bool isFavourite(int productId) => _store.containsKey(productId);

  @override
  void toggle(Product product) {
    if (_store.containsKey(product.id)) {
      _store.remove(product.id);
    } else {
      _store[product.id] = product;
    }
  }
}

const _product = Product(
  id: 7,
  title: 'Wireless Earbuds',
  description: 'Noise-cancelling earbuds.',
  category: 'electronics',
  price: 50,
  discountPercentage: 0,
  rating: 4.2,
  stock: 10,
  brand: 'Acme',
  thumbnail: 'https://example.com/thumb.jpg',
  images: [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _InMemoryFavouritesRepository repository;
  late FavouritesCubit cubit;

  setUp(() {
    repository = _InMemoryFavouritesRepository();
    cubit = FavouritesCubit(repository);
  });

  test('starts empty when nothing is persisted', () {
    expect(cubit.state.favourites, isEmpty);
  });

  test('toggle adds a product and persists it', () {
    cubit.toggle(_product);

    expect(cubit.isFavourite(_product.id), isTrue);
    expect(cubit.state.favourites, contains(_product));
    expect(repository.getAll(), contains(_product));
  });

  test('toggling twice removes the product again', () {
    cubit.toggle(_product);
    cubit.toggle(_product);

    expect(cubit.isFavourite(_product.id), isFalse);
    expect(cubit.state.favourites, isEmpty);
    expect(repository.getAll(), isEmpty);
  });

  test('a fresh cubit picks up previously persisted favourites', () {
    repository.toggle(_product);

    final restored = FavouritesCubit(repository);

    expect(restored.isFavourite(_product.id), isTrue);
  });
}
