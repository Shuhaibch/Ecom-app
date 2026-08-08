import 'package:flutter_test/flutter_test.dart';

import 'package:ecom/core/theme/app_theme.dart';

void main() {
  test('AppTheme.light uses Material 3', () {
    expect(AppTheme.light.useMaterial3, isTrue);
  });
}
