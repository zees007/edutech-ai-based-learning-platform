import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devzees_edutechai_client/presentation/pages/subscription/subscription_page.dart';

void main() {
  testWidgets('SubscriptionPage renders without layout overflow on standard desktop screen', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SubscriptionPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Supercharge Your AI Learning'), findsOneWidget);
    expect(find.text('Plans & Pricing'), findsOneWidget);
    expect(find.text('Billing & Settings'), findsOneWidget);
    expect(find.text('Invoice Records'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(find.text('Pro'), findsOneWidget);
    expect(find.text('Ultra'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SubscriptionPage renders without layout overflow on compact screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SubscriptionPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Supercharge Your AI Learning'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
