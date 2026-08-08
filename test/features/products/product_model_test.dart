import 'package:flutter_test/flutter_test.dart';

import 'package:ecom/features/products/data/models/product_model.dart';
import 'package:ecom/features/products/data/models/products_response_model.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('parses a well-formed product', () {
      final model = ProductModel.fromJson({
        'id': 1,
        'title': 'Phone',
        'description': 'A phone',
        'category': 'smartphones',
        'price': 599.99,
        'discountPercentage': 12.5,
        'rating': 4.3,
        'stock': 20,
        'brand': 'Acme',
        'thumbnail': 'https://example.com/thumb.jpg',
        'images': ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
      });

      expect(model.id, 1);
      expect(model.title, 'Phone');
      expect(model.price, 599.99);
      expect(model.discountPercentage, 12.5);
      expect(model.stock, 20);
      expect(model.images, hasLength(2));
    });

    test('falls back to safe defaults for missing fields instead of throwing', () {
      final model = ProductModel.fromJson(const {'id': 1, 'title': 'Phone'});

      expect(model.id, 1);
      expect(model.description, '');
      expect(model.category, '');
      expect(model.price, 0.0);
      expect(model.discountPercentage, 0.0);
      expect(model.rating, 0.0);
      expect(model.stock, 0);
      expect(model.brand, '');
      expect(model.thumbnail, '');
      expect(model.images, isEmpty);
    });

    test('coerces numbers arriving as strings instead of throwing', () {
      final model = ProductModel.fromJson(const {
        'id': '7',
        'title': 'Phone',
        'price': '19.99',
        'stock': '5',
      });

      expect(model.id, 7);
      expect(model.price, 19.99);
      expect(model.stock, 5);
    });

    test('ignores non-list "images" instead of throwing', () {
      final model = ProductModel.fromJson(const {
        'id': 1,
        'title': 'Phone',
        'images': 'not-a-list',
      });

      expect(model.images, isEmpty);
    });

    test('round-trips through toJson', () {
      final model = ProductModel.fromJson({
        'id': 1,
        'title': 'Phone',
        'description': 'A phone',
        'category': 'smartphones',
        'price': 599.99,
        'discountPercentage': 12.5,
        'rating': 4.3,
        'stock': 20,
        'brand': 'Acme',
        'thumbnail': 'https://example.com/thumb.jpg',
        'images': ['https://example.com/1.jpg'],
      });

      final restored = ProductModel.fromJson(model.toJson());

      expect(restored.id, model.id);
      expect(restored.title, model.title);
      expect(restored.price, model.price);
      expect(restored.images, model.images);
    });
  });

  group('ProductsResponseModel.fromJson', () {
    test('parses products, total, skip and limit', () {
      final response = ProductsResponseModel.fromJson({
        'products': [
          {'id': 1, 'title': 'A'},
          {'id': 2, 'title': 'B'},
        ],
        'total': 100,
        'skip': 0,
        'limit': 2,
      });

      expect(response.products, hasLength(2));
      expect(response.total, 100);
      expect(response.skip, 0);
      expect(response.limit, 2);
    });

    test('skips non-object entries in "products" instead of throwing', () {
      final response = ProductsResponseModel.fromJson({
        'products': [
          {'id': 1, 'title': 'A'},
          'not-a-product',
          null,
        ],
        'total': 1,
        'skip': 0,
        'limit': 20,
      });

      expect(response.products, hasLength(1));
      expect(response.products.single.id, 1);
    });

    test('defaults to an empty list when "products" is missing or malformed', () {
      final response = ProductsResponseModel.fromJson(const {'total': 0});

      expect(response.products, isEmpty);
      expect(response.total, 0);
    });
  });
}
