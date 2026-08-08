import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ecom/core/router/app_routes.dart';
import 'package:ecom/core/widgets/app_empty_view.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:ecom/features/favourites/presentation/bloc/favourites_cubit.dart';
import 'package:ecom/features/favourites/presentation/bloc/favourites_state.dart';
import 'package:ecom/features/products/domain/entities/product.dart';
import 'package:ecom/features/products/presentation/widgets/product_card.dart';
import 'package:ecom/l10n/app_localizations.dart';

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FavouritesCubit, FavouritesState>(
      builder: (context, state) {
        if (state.favourites.isEmpty) {
          return AppEmptyView(
            icon: Icons.favorite_border,
            title: l10n.emptyFavouritesTitle,
            description: l10n.emptyFavouritesDescription,
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          itemCount: state.favourites.length,
          itemBuilder: (context, index) {
            final product = state.favourites[index];
            return _FavouriteGridItem(key: ValueKey(product.id), product: product);
          },
        );
      },
    );
  }
}

class _FavouriteGridItem extends StatefulWidget {
  final Product product;

  const _FavouriteGridItem({super.key, required this.product});

  @override
  State<_FavouriteGridItem> createState() => _FavouriteGridItemState();
}

class _FavouriteGridItemState extends State<_FavouriteGridItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Only newly-favourited items get a fresh State (existing ones keep
    // theirs across rebuilds thanks to the ValueKey), so this entrance
    // animation naturally plays only for items just added to the grid.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartQuantity = context.select<CartCubit, int>(
      (cubit) => cubit.quantityOf(product.id),
    );
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      child: FadeTransition(
        opacity: _controller,
        child: ProductCard(
          product: product,
          isFavourite: true,
          cartQuantity: cartQuantity,
          onTap: () => context.push(AppRoutes.productDetailsPath(product.id)),
          onFavouriteToggle: () =>
              context.read<FavouritesCubit>().toggle(product),
          onAddToCart: () => context.read<CartCubit>().increment(product),
        ),
      ),
    );
  }
}
