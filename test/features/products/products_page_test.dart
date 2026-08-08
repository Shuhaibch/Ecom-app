import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal reproduction of a real bug hit while building the products
/// grid: provider's `context.select` refuses to run directly inside a
/// SliverChildBuilderDelegate's itemBuilder (the delegate for
/// GridView.builder/ListView.builder), because a selecting widget there
/// can't be scoped to just that item without risking a rebuild of the
/// whole list. The fix is to extract a child widget so `select` runs in
/// its own BuildContext instead of the itemBuilder's raw context —
/// exactly what `_ProductGridItem` in products_page.dart does.
class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);
}

void main() {
  testWidgets(
    'context.select directly inside GridView.builder itemBuilder throws',
    (tester) async {
      await tester.pumpWidget(
        BlocProvider(
          create: (_) => _CounterCubit(),
          child: MaterialApp(
            home: GridView.builder(
              itemCount: 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
              ),
              itemBuilder: (context, index) {
                final value = context.select<_CounterCubit, int>((c) => c.state);
                return Text('$value');
              },
            ),
          ),
        ),
      );

      expect(tester.takeException(), isAssertionError);
    },
  );

  testWidgets(
    'extracting a child widget lets context.select run safely inside the grid',
    (tester) async {
      await tester.pumpWidget(
        BlocProvider(
          create: (_) => _CounterCubit(),
          child: MaterialApp(
            home: GridView.builder(
              itemCount: 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
              ),
              itemBuilder: (context, index) => const _GridItem(),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('0'), findsOneWidget);
    },
  );
}

class _GridItem extends StatelessWidget {
  const _GridItem();

  @override
  Widget build(BuildContext context) {
    final value = context.select<_CounterCubit, int>((c) => c.state);
    return Text('$value');
  }
}
