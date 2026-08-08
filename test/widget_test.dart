import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecom/core/localization/locale_cubit.dart';
import 'package:ecom/core/localization/locale_toggle_button.dart';
import 'package:ecom/core/theme/app_theme.dart';
import 'package:ecom/l10n/app_localizations.dart';

void main() {
  test('AppTheme.light uses Material 3', () {
    expect(AppTheme.light.useMaterial3, isTrue);
  });

  testWidgets('switching language flips layout direction to RTL for Arabic', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => LocaleCubit(),
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              locale: locale,
              supportedLocales: LocaleCubit.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Builder(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text(AppLocalizations.of(context)!.navProducts),
                    actions: const [LocaleToggleButton()],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(Scaffold))), TextDirection.ltr);
    expect(find.text('Products'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();

    expect(Directionality.of(tester.element(find.byType(Scaffold))), TextDirection.rtl);
    expect(find.text('المنتجات'), findsOneWidget);
  });
}
