import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ecom/core/widgets/app_empty_view.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:ecom/features/cart/presentation/bloc/cart_state.dart';
import 'package:ecom/features/cart/presentation/widgets/cart_item_tile.dart';
import 'package:ecom/features/cart/presentation/widgets/cart_summary.dart';
import 'package:ecom/l10n/app_localizations.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return CartItemTile(
                    item: item,
                    onIncrement: () => cubit.increment(item.product),
                    onDecrement: () => cubit.decrement(item.product),
                    onRemove: () => cubit.removeItem(item.product),
                  );
                },
              ),
            ),
            CartSummary(
              subtotal: state.subtotal,
              discount: state.discount,
              total: state.total,
            ),
          ],
        );
      },
    );
  }
}
