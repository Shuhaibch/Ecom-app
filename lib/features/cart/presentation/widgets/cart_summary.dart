import 'package:flutter/material.dart';

import 'package:ecom/l10n/app_localizations.dart';

class CartSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double total;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow(label: l10n.subtotal, value: subtotal),
            if (discount > 0)
              _SummaryRow(
                label: l10n.discountLabel,
                value: -discount,
                valueColor: colorScheme.error,
              ),
            const Divider(height: 20),
            _SummaryRow(
              label: l10n.total,
              value: total,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final TextStyle? style;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.style,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final sign = value < 0 ? '-' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            '$sign\$${value.abs().toStringAsFixed(2)}',
            style: (style ?? const TextStyle()).copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
