import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ecom/core/router/app_routes.dart';
import 'package:ecom/core/widgets/app_empty_view.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecom/features/cart/presentation/widgets/animated_cart_list.dart';
import 'package:ecom/features/cart/presentation/widgets/cart_summary.dart';
import 'package:ecom/features/cart/presentation/widgets/confirm_order_sheet.dart';
import 'package:ecom/l10n/app_localizations.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> _handleBuyNow(
    BuildContext context,
    CartCubit cubit,
    double total,
  ) async {
    final confirmed = await showConfirmOrderSheet(context, total);
    if (confirmed != true || !context.mounted) return;

    cubit.checkout();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.orderPlacedMessage)),
      );
    context.go(AppRoutes.products);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.isEmpty) {
          return AppEmptyView(
            icon: Icons.shopping_bag_outlined,
            title: l10n.emptyCartTitle,
            description: l10n.emptyCartDescription,
          );
        }

        final cubit = context.read<CartCubit>();
        return Column(
          children: [
            Expanded(
              child: AnimatedCartList(
                items: state.items,
                onIncrement: (item) => cubit.increment(item.product),
                onDecrement: (item) => cubit.decrement(item.product),
                onRemove: (item) => cubit.removeItem(item.product),
              ),
            ),
            CartSummary(
              subtotal: state.subtotal,
              discount: state.discount,
              total: state.total,
              onBuyNow: () => _handleBuyNow(context, cubit, state.total),
            ),
          ],
        );
      },
    );
  }
}
