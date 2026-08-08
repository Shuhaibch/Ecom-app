import 'package:flutter_test/flutter_test.dart';

import 'package:ecom/features/cart/domain/entities/cart_item.dart';
import 'package:ecom/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:ecom/features/products/domain/entities/product.dart';

class _InMemoryCartRepository implements CartRepository {
  final Map<int, CartItem> _store = {};

  @override
  List<CartItem> getAll() => _store.values.toList();

  @override
  void setQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      _store.remove(product.id);
    } else {
      _store[product.id] = CartItem(product: product, quantity: quantity);
    }
  }
}

Product _product({int id = 1, double price = 50, double discount = 0, int stock = 3}) {
  return Product(
    id: id,
    title: 'Product $id',
    description: 'Description',
    category: 'electronics',
    price: price,
    discountPercentage: discount,
    rating: 4,
    stock: stock,
    brand: 'Acme',
    thumbnail: 'https://example.com/thumb.jpg',
    images: const [],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _InMemoryCartRepository repository;
  late CartCubit cubit;

  setUp(() {
    repository = _InMemoryCartRepository();
    cubit = CartCubit(repository);
  });

  test('starts empty when nothing is persisted', () {
    expect(cubit.state.isEmpty, isTrue);
  });

  test('increment adds a new item with quantity 1', () {
    final product = _product();
    cubit.increment(product);

    expect(cubit.quantityOf(product.id), 1);
    expect(repository.getAll(), hasLength(1));
  });

  test('increment does not exceed available stock', () {
    final product = _product(stock: 2);
    cubit.increment(product);
    cubit.increment(product);
    cubit.increment(product);

    expect(cubit.quantityOf(product.id), 2);
  });

  test('decrement below 1 removes the item', () {
    final product = _product();
    cubit.increment(product);
    cubit.decrement(product);

    expect(cubit.quantityOf(product.id), 0);
    expect(repository.getAll(), isEmpty);
  });

  test('removeItem clears the item regardless of quantity', () {
    final product = _product();
    cubit.increment(product);
    cubit.increment(product);
    cubit.removeItem(product);

    expect(cubit.quantityOf(product.id), 0);
  });

  test('subtotal, discount and total are computed correctly', () {
    final product = _product(price: 100, discount: 10); // discounted: 90
    cubit.increment(product);
    cubit.increment(product); // quantity 2

    expect(cubit.state.subtotal, 200);
    expect(cubit.state.discount, 20);
    expect(cubit.state.total, 180);
  });

  test('a fresh cubit picks up previously persisted cart items', () {
    final product = _product();
    repository.setQuantity(product, 3);

    final restored = CartCubit(repository);

    expect(restored.quantityOf(product.id), 3);
  });
}
