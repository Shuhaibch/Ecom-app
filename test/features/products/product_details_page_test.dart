import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecom/core/error/failures.dart';
import 'package:ecom/core/utils/result.dart';
import 'package:ecom/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:ecom/features/favourites/presentation/bloc/favourites_cubit.dart';
import 'package:ecom/features/products/domain/entities/product.dart';
import 'package:ecom/features/products/domain/repositories/products_repository.dart';
import 'package:ecom/features/products/domain/usecases/get_product_by_id.dart';
import 'package:ecom/features/products/presentation/bloc/product_details_cubit.dart';
import 'package:ecom/features/products/presentation/pages/product_details_page.dart';
import 'package:ecom/l10n/app_localizations.dart';

class _FakeFavouritesRepository implements FavouritesRepository {
  final Set<int> _ids = {};

  @override
  List<Product> getAll() => const [];

  @override
  bool isFavourite(int productId) => _ids.contains(productId);

  @override
  void toggle(Product product) {
    if (!_ids.add(product.id)) _ids.remove(product.id);
  }
}

class _FakeGetProductById implements GetProductById {
  final Future<Result<Product>> Function(GetProductByIdParams) handler;
  int callCount = 0;

  _FakeGetProductById(this.handler);

  @override
  ProductsRepository get repository => throw UnimplementedError();

  @override
  Future<Result<Product>> call(GetProductByIdParams params) async {
    callCount++;
    return handler(params);
  }
}

const _product = Product(
  id: 1,
  title: 'Test Sneakers',
  description: 'Comfortable everyday sneakers.',
  category: 'shoes',
  price: 100,
  discountPercentage: 10,
  rating: 4.5,
  stock: 5,
  brand: 'Acme',
  thumbnail: 'https://example.com/thumb.jpg',
  images: ['https://example.com/thumb.jpg'],
);

Future<void> _pumpDetails(WidgetTester tester, GetProductById useCase) async {
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProductDetailsCubit(useCase)..load(1)),
        BlocProvider(
          create: (_) => FavouritesCubit(_FakeFavouritesRepository()),
        ),
      ],
      child: MaterialApp(
        supportedLocales: const [Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const ProductDetailsView(productId: 1),
      ),
    ),
  );
}

void main() {
  testWidgets('shows product details on successful load', (tester) async {
    final useCase = _FakeGetProductById((_) async => const Ok(_product));

    await _pumpDetails(tester, useCase);
    await tester.pump();

    expect(find.text('Test Sneakers'), findsOneWidget);
    expect(find.text('Comfortable everyday sneakers.'), findsOneWidget);
    expect(find.text('\$90.00'), findsOneWidget);
    expect(useCase.callCount, 1);
  });

  testWidgets('shows error view on failure and retries on tap', (tester) async {
    final useCase = _FakeGetProductById((_) async => const Err(NetworkFailure()));

    await _pumpDetails(tester, useCase);
    await tester.pump();

    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    expect(useCase.callCount, 1);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    expect(useCase.callCount, 2);
  });
}
