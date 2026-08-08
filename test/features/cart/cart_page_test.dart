import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ecom/features/cart/domain/entities/cart_item.dart';
import 'package:ecom/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:ecom/features/cart/presentation/pages/cart_page.dart';
import 'package:ecom/features/products/domain/entities/product.dart';
import 'package:ecom/l10n/app_localizations.dart';

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

  @override
  void clear() => _store.clear();
}

const _product = Product(
  id: 1,
  title: 'Wireless Mouse',
  description: 'Ergonomic wireless mouse.',
  category: 'electronics',
  price: 40,
  discountPercentage: 0,
  rating: 4.1,
  stock: 5,
  brand: 'Acme',
  thumbnail: 'https://example.com/thumb.jpg',
  images: [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'confirming the buy-now sheet clears the cart and redirects home',
    (tester) async {
      final repository = _InMemoryCartRepository();
      final cubit = CartCubit(repository)..increment(_product);

      final router = GoRouter(
        initialLocation: '/cart',
        routes: [
          GoRoute(path: '/products', builder: (_, _) => const Text('Home')),
          GoRoute(
            path: '/cart',
            builder: (_, _) => BlocProvider.value(
              value: cubit,
              child: const Scaffold(body: CartPage()),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          supportedLocales: const [Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Wireless Mouse'), findsOneWidget);

      await tester.tap(find.text('Buy Now'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm your order'), findsOneWidget);

      await tester.tap(find.text('Confirm Order'));
      // Two short pumps: enough for the sheet's dismiss animation to
      // finish and _handleBuyNow's post-await code (checkout + snackbar
      // + navigate) to run, but before the page-transition animation
      // finishes and disposes the old Scaffold the snackbar is on.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(cubit.state.isEmpty, isTrue);
      expect(find.text('Your order has been placed!'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      await cubit.close();
    },
  );

  testWidgets('cancelling the sheet keeps the cart untouched', (tester) async {
    final repository = _InMemoryCartRepository();
    final cubit = CartCubit(repository)..increment(_product);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          supportedLocales: const [Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const Scaffold(body: CartPage()),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Buy Now'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(cubit.state.isEmpty, isFalse);
    expect(cubit.quantityOf(_product.id), 1);

    await cubit.close();
  });
}
