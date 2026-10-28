import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glass_card.dart';
import 'package:devzees_edutechai_client/presentation/widgets/app_gradient_spinner.dart';

void main() {
  testWidgets('GlassCard renders in default and glowing states without gradient assertion errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              GlassCard(
                isGlowing: false,
                child: Text('Card 1'),
              ),
              GlassCard(
                isGlowing: true,
                child: Text('Card 2'),
              ),
              AppGradientSpinner(),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Card 1'), findsOneWidget);
    expect(find.text('Card 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
