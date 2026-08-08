import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:ecom/features/favourites/data/repositories/favourites_repository_impl.dart';
import 'package:ecom/features/products/domain/entities/product.dart';

const _product = Product(
  id: 42,
  title: 'Noise Cancelling Headphones',
  description: 'Over-ear, 30h battery.',
  category: 'electronics',
  price: 149.99,
  discountPercentage: 5,
  rating: 4.6,
  stock: 8,
  brand: 'Acme',
  thumbnail: 'https://example.com/thumb.jpg',
  images: ['https://example.com/1.jpg'],
);

void main() {
  late Directory tempDir;
  late Box<String> box;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('favourites_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<String>('favourites_test_box');
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('toggle persists the full product to the real Hive box', () {
    final repository = FavouritesRepositoryImpl(box);

    repository.toggle(_product);

    expect(repository.isFavourite(_product.id), isTrue);
    expect(box.containsKey('42'), isTrue);

    final restored = repository.getAll().single;
    expect(restored.id, _product.id);
    expect(restored.title, _product.title);
    expect(restored.price, _product.price);
  });

  test('toggling twice removes it from the box again', () {
    final repository = FavouritesRepositoryImpl(box);

    repository.toggle(_product);
    repository.toggle(_product);

    expect(repository.isFavourite(_product.id), isFalse);
    expect(box.isEmpty, isTrue);
  });

  test('a new repository instance over the same box sees prior writes', () {
    FavouritesRepositoryImpl(box).toggle(_product);

    final reopened = FavouritesRepositoryImpl(box);

    expect(reopened.isFavourite(_product.id), isTrue);
    expect(reopened.getAll(), hasLength(1));
  });
}
