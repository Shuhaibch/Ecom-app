import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecom/core/theme/app_theme.dart';
import 'package:ecom/main.dart';

void main() {
  test('AppTheme.light uses Material 3', () {
    expect(AppTheme.light.useMaterial3, isTrue);
  });

  testWidgets('switching language flips layout direction to RTL for Arabic', (
    tester,
  ) async {
    await tester.pumpWidget(const EcomApp());
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.ltr);
    expect(find.text('Products'), findsWidgets);

    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.rtl);
    expect(find.text('المنتجات'), findsWidgets);
  });
}
