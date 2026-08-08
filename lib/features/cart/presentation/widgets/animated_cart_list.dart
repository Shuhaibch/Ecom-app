import 'package:flutter/material.dart';

import 'package:ecom/features/cart/domain/entities/cart_item.dart';
import 'package:ecom/features/cart/presentation/widgets/cart_item_tile.dart';

class AnimatedCartList extends StatefulWidget {
  final List<CartItem> items;
  final void Function(CartItem item) onIncrement;
  final void Function(CartItem item) onDecrement;
  final void Function(CartItem item) onRemove;

  const AnimatedCartList({
    super.key,
    required this.items,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  State<AnimatedCartList> createState() => _AnimatedCartListState();
}

class _AnimatedCartListState extends State<AnimatedCartList> {
  final _listKey = GlobalKey<AnimatedListState>();
  late List<CartItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.items);
  }

  @override
  void didUpdateWidget(covariant AnimatedCartList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncWith(widget.items);
  }

  void _syncWith(List<CartItem> newItems) {
    for (var i = _items.length - 1; i >= 0; i--) {
      final id = _items[i].product.id;
      if (!newItems.any((item) => item.product.id == id)) {
        final removed = _items.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildItem(removed, animation),
          duration: const Duration(milliseconds: 250),
        );
      }
    }

    for (var i = 0; i < newItems.length; i++) {
      final newItem = newItems[i];
      final existingIndex = _items.indexWhere(
        (item) => item.product.id == newItem.product.id,
      );
      if (existingIndex == -1) {
        _items.insert(i, newItem);
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        _items[existingIndex] = newItem;
      }
    }
  }

  Widget _buildItem(CartItem item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: animation,
        child: Column(
          children: [
            CartItemTile(
              item: item,
              onIncrement: () => widget.onIncrement(item),
              onDecrement: () => widget.onDecrement(item),
              onRemove: () => widget.onRemove(item),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      padding: const EdgeInsets.symmetric(vertical: 12),
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) =>
          _buildItem(_items[index], animation),
    );
  }
}
