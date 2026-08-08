import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders an amount prefixed with the UAE Dirham symbol icon, e.g. the
/// Dirham glyph followed by "19.99". The icon is tinted to match the
/// surrounding text color (e.g. red on a discount row, grey on a
/// struck-through original price) since it's a single-color SVG.
///
/// Built as a single [Text.rich] (icon as a [WidgetSpan]) rather than a
/// Row of [Text] + icon, so it lays out correctly inside the app's
/// baseline-aligned price rows (discounted vs. struck-through original
/// price) instead of needing special-casing at every call site.
class PriceText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final TextOverflow overflow;
  final bool negative;

  const PriceText({
    super.key,
    required this.amount,
    this.style,
    this.overflow = TextOverflow.clip,
    this.negative = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = DefaultTextStyle.of(context).style.merge(style);
    final iconColor = effectiveStyle.color ?? Theme.of(context).colorScheme.onSurface;
    final iconSize = (effectiveStyle.fontSize ?? 14) * 0.85;

    return Text.rich(
      TextSpan(
        children: [
          if (negative) const TextSpan(text: '-'),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: SvgPicture.asset(
                'assets/images/dirham_icon.svg',
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          TextSpan(text: amount.abs().toStringAsFixed(2)),
        ],
      ),
      style: style,
      overflow: overflow,
    );
  }
}
