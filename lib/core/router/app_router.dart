import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ecom/core/router/app_routes.dart';
import 'package:ecom/core/router/app_shell.dart';
import 'package:ecom/core/router/placeholder_page.dart';

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
              builder: (context, state) =>
                  const PlaceholderPage(title: 'Products'),
              routes: [
                GoRoute(
                  path: AppRoutes.productDetails,
                  builder: (context, state) =>
                      const PlaceholderPage(title: 'Product details'),
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
                  const PlaceholderPage(title: 'Favourites'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.cart,
              builder: (context, state) => const PlaceholderPage(title: 'Cart'),
            ),
          ],
        ),
      ],
    ),
  ],
);
