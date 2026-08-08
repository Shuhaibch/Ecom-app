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
            return _FavouriteGridItem(product: state.favourites[index]);
          },
        );
      },
    );
  }
}

class _FavouriteGridItem extends StatelessWidget {
  final Product product;

  const _FavouriteGridItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final cartQuantity = context.select<CartCubit, int>(
      (cubit) => cubit.quantityOf(product.id),
    );
    return ProductCard(
      product: product,
      isFavourite: true,
      cartQuantity: cartQuantity,
      onTap: () => context.push(AppRoutes.productDetailsPath(product.id)),
      onFavouriteToggle: () => context.read<FavouritesCubit>().toggle(product),
      onAddToCart: () => context.read<CartCubit>().increment(product),
    );
  }
}
