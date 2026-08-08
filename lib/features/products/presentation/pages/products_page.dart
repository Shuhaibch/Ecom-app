import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ecom/core/di/injection_container.dart';
import 'package:ecom/core/router/app_routes.dart';
import 'package:ecom/core/widgets/app_empty_view.dart';
import 'package:ecom/core/widgets/app_error_view.dart';
import 'package:ecom/core/widgets/offline_banner.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:ecom/features/favourites/presentation/bloc/favourites_cubit.dart';
import 'package:ecom/features/products/domain/entities/product.dart';
import 'package:ecom/features/products/presentation/bloc/products_bloc.dart';
import 'package:ecom/features/products/presentation/bloc/products_event.dart';
import 'package:ecom/features/products/presentation/bloc/products_state.dart';
import 'package:ecom/features/products/presentation/widgets/category_filter_chips.dart';
import 'package:ecom/features/products/presentation/widgets/product_card.dart';
import 'package:ecom/features/products/presentation/widgets/products_grid_skeleton.dart';
import 'package:ecom/features/products/presentation/widgets/products_search_bar.dart';
import 'package:ecom/core/error/failure_localizer.dart';
import 'package:ecom/l10n/app_localizations.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductsBloc>()..add(const ProductsStarted()),
      child: const ProductsView(),
    );
  }
}

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      context.read<ProductsBloc>().add(const ProductsNextPageRequested());
    }
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<ProductsBloc>();
    bloc.add(const ProductsRefreshRequested());
    await bloc.stream.firstWhere(
      (s) => s.status != ProductsStatus.refreshing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsBloc, ProductsState>(
      listenWhen: (previous, current) =>
          current.transientFailure != null &&
          previous.transientFailure != current.transientFailure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(localizeFailure(context, state.transientFailure!)),
            ),
          );
      },
      builder: (context, state) {
        if (_searchController.text != state.searchQuery) {
          _searchController.value = _searchController.value.copyWith(
            text: state.searchQuery,
            selection: TextSelection.collapsed(offset: state.searchQuery.length),
          );
        }

        return Column(
          children: [
            if (state.isOffline) const OfflineBanner(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: ProductsSearchBar(
                controller: _searchController,
                onChanged: (query) => context.read<ProductsBloc>().add(
                  ProductsSearchQueryChanged(query),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CategoryFilterChips(
                categories: state.categories,
                selectedCategory: state.selectedCategory,
                onSelected: (category) => context.read<ProductsBloc>().add(
                  ProductsCategorySelected(category),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProductsState state) {
    switch (state.status) {
      case ProductsStatus.initial:
      case ProductsStatus.loading:
        return const ProductsGridSkeleton();

      case ProductsStatus.failure:
        return AppErrorView(
          failure: state.loadFailure!,
          onRetry: () =>
              context.read<ProductsBloc>().add(const ProductsRefreshRequested()),
        );

      case ProductsStatus.loadingMore:
      case ProductsStatus.refreshing:
      case ProductsStatus.success:
        if (state.isEmptyResult) {
          final l10n = AppLocalizations.of(context)!;
          return AppEmptyView(
            icon: state.isSearching || state.selectedCategory != null
                ? Icons.search_off_rounded
                : Icons.inventory_2_outlined,
            title: l10n.noResultsFoundTitle,
            description: l10n.noResultsFoundDescription,
          );
        }
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemCount: state.products.length + (state.status == ProductsStatus.loadingMore ? 2 : 0),
            itemBuilder: (context, index) {
              if (index >= state.products.length) {
                return const _PaginationSkeletonCard();
              }
              return _ProductGridItem(product: state.products[index]);
            },
          ),
        );
    }
  }
}

class _ProductGridItem extends StatelessWidget {
  final Product product;

  const _ProductGridItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final isFavourite = context.select<FavouritesCubit, bool>(
      (cubit) => cubit.isFavourite(product.id),
    );
    final cartQuantity = context.select<CartCubit, int>(
      (cubit) => cubit.quantityOf(product.id),
    );
    return ProductCard(
      product: product,
      isFavourite: isFavourite,
      onFavouriteToggle: () => context.read<FavouritesCubit>().toggle(product),
      cartQuantity: cartQuantity,
      onAddToCart: () => context.read<CartCubit>().increment(product),
      onTap: () => context.push(AppRoutes.productDetailsPath(product.id)),
    );
  }
}

class _PaginationSkeletonCard extends StatelessWidget {
  const _PaginationSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
