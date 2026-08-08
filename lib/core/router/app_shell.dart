import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ecom/core/localization/locale_toggle_button.dart';
import 'package:ecom/core/widgets/bounce_on_change.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:ecom/features/favourites/presentation/bloc/favourites_cubit.dart';
import 'package:ecom/l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titles = [l10n.navProducts, l10n.navFavourites, l10n.navCart];
    final cartCount = context.select<CartCubit, int>((c) => c.state.itemCount);
    final favouritesCount = context.select<FavouritesCubit, int>(
      (c) => c.state.favourites.length,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[navigationShell.currentIndex]),
        actions: const [LocaleToggleButton()],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          navigationShell.goBranch(index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: l10n.navProducts,
          ),
          NavigationDestination(
            icon: BounceOnChange(
              value: favouritesCount,
              child: const Icon(Icons.favorite_border),
            ),
            selectedIcon: BounceOnChange(
              value: favouritesCount,
              child: const Icon(Icons.favorite),
            ),
            label: l10n.navFavourites,
          ),
          NavigationDestination(
            icon: BounceOnChange(
              value: cartCount,
              child: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
            selectedIcon: BounceOnChange(
              value: cartCount,
              child: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_bag),
              ),
            ),
            label: l10n.navCart,
          ),
        ],
      ),
    );
  }
}
