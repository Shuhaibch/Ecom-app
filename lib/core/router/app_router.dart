import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ecom/core/router/app_routes.dart';
import 'package:ecom/core/router/app_shell.dart';
import 'package:ecom/core/router/placeholder_page.dart';
import 'package:ecom/features/products/presentation/pages/product_details_page.dart';
import 'package:ecom/features/products/presentation/pages/products_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.products,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.products,
              builder: (context, state) => const ProductsPage(),
              routes: [
                GoRoute(
                  path: AppRoutes.productDetails,
                  // Pushed on the root navigator so it covers the bottom
                  // nav and shell AppBar instead of nesting inside them.
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = int.tryParse(state.pathParameters['id'] ?? '');
                    if (id == null) {
                      return const PlaceholderPage(title: 'Product details');
                    }
                    return ProductDetailsPage(productId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.favourites,
              builder: (context, state) =>
                  const PlaceholderBody(title: 'Favourites'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.cart,
              builder: (context, state) =>
                  const PlaceholderBody(title: 'Cart'),
            ),
          ],
        ),
      ],
    ),
  ],
);
