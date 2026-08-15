import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shepit/main.dart';

void main() {
  testWidgets('Shepit resolves the system language for its primary navigation', (tester) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    await tester.pumpWidget(const ShepitApp());
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
