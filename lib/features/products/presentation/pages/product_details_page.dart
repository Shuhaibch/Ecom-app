import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ecom/core/di/injection_container.dart';
import 'package:ecom/core/widgets/app_error_view.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:ecom/features/favourites/presentation/bloc/favourites_cubit.dart';
import 'package:ecom/features/products/domain/entities/product.dart';
import 'package:ecom/features/products/presentation/bloc/product_details_cubit.dart';
import 'package:ecom/features/products/presentation/bloc/product_details_state.dart';
import 'package:ecom/features/products/presentation/widgets/products_grid_skeleton.dart';
import 'package:ecom/l10n/app_localizations.dart';

class ProductDetailsPage extends StatelessWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductDetailsCubit>()..load(productId),
      child: ProductDetailsView(productId: productId),
    );
  }
}

class ProductDetailsView extends StatelessWidget {
  final int productId;

  const ProductDetailsView({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          switch (state.status) {
            case ProductDetailsStatus.loading:
              return Column(
                children: [
                  AppBar(),
                  const Expanded(child: ProductsGridSkeleton()),
                ],
              );
            case ProductDetailsStatus.failure:
              return Column(
                children: [
                  AppBar(),
                  Expanded(
                    child: AppErrorView(
                      failure: state.failure!,
                      onRetry: () => context
                          .read<ProductDetailsCubit>()
                          .load(productId),
                    ),
                  ),
                ],
              );
            case ProductDetailsStatus.success:
              return _ProductDetailsContent(product: state.product!);
          }
        },
      ),
    );
  }
}

class _ProductDetailsContent extends StatefulWidget {
  final Product product;

  const _ProductDetailsContent({required this.product});

  @override
  State<_ProductDetailsContent> createState() => _ProductDetailsContentState();
}

class _ProductDetailsContentState extends State<_ProductDetailsContent> {
  final _pageController = PageController();
  int _imageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final product = widget.product;
    final images = product.images.isNotEmpty ? product.images : [product.thumbnail];
    final hasDiscount = product.discountPercentage > 0;

    final scrollView = CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 320,
          actions: [
            Builder(
              builder: (context) {
                final isFavourite = context.select<FavouritesCubit, bool>(
                  (cubit) => cubit.isFavourite(product.id),
                );
                return IconButton(
                  icon: Icon(
                    isFavourite ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: isFavourite ? colorScheme.error : null,
                  tooltip: isFavourite
                      ? l10n.removeFromFavourites
                      : l10n.addToFavourites,
                  onPressed: () =>
                      context.read<FavouritesCubit>().toggle(product),
                );
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _imageIndex = i),
                  itemBuilder: (context, index) {
                    final tag = index == 0 ? 'product-image-${product.id}' : null;
                    final image = CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: colorScheme.surfaceContainerHigh),
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.surfaceContainerHigh,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: colorScheme.outline,
                        ),
                      ),
                    );
                    return tag == null ? image : Hero(tag: tag, child: image);
                  },
                ),
                if (images.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _imageIndex ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _imageIndex
                                ? colorScheme.primary
                                : colorScheme.surface.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category,
                  style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Text(product.title, style: textTheme.headlineSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 4),
                    Text(product.rating.toStringAsFixed(1), style: textTheme.bodyMedium),
                    const SizedBox(width: 16),
                    Icon(
                      product.isOutOfStock ? Icons.cancel_outlined : Icons.check_circle_outline,
                      size: 18,
                      color: product.isOutOfStock ? colorScheme.error : Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.stockStatus(product.stock),
                      style: textTheme.bodyMedium?.copyWith(
                        color: product.isOutOfStock ? colorScheme.error : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$${product.discountedPrice.toStringAsFixed(2)}',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: colorScheme.onErrorContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                Text(l10n.descriptionLabel, style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );

    return Stack(
      children: [
        scrollView,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _AddToCartBar(product: product),
        ),
      ],
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  final Product product;

  const _AddToCartBar({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Builder(
          builder: (context) {
            final quantity = context.select<CartCubit, int>(
              (cubit) => cubit.quantityOf(product.id),
            );

            if (quantity == 0) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: product.isOutOfStock
                      ? null
                      : () => context.read<CartCubit>().increment(product),
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: Text(l10n.addToCart),
                ),
              );
            }

            return Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<CartCubit>().decrement(product),
                    icon: const Icon(Icons.remove),
                    label: Text('${l10n.quantity}: $quantity'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: quantity >= product.stock
                      ? null
                      : () => context.read<CartCubit>().increment(product),
                  icon: const Icon(Icons.add),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
