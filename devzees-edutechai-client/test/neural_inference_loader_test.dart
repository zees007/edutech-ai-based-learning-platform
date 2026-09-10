import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/main_content/neural_inference_loader.dart';

void main() {
  testWidgets('NeuralInferenceLoader renders centered on mobile viewport', (WidgetTester tester) async {
    // Set mobile viewport
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NeuralInferenceLoader(
            title: 'Synthesizing Step 1: Photosynthesis',
            subtitle: 'Orchestrating agents and provisioning neural resources...',
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    // Verify Title and Subtitle exist
    expect(find.text('Synthesizing Step 1: Photosynthesis'), findsOneWidget);
    expect(find.text('Orchestrating agents and provisioning neural resources...'), findsOneWidget);

    // Verify AI Compute Cluster & Live Inference badge exist
    expect(find.text('AI COMPUTE CLUSTER'), findsOneWidget);
    expect(find.text('LIVE INFERENCE'), findsOneWidget);

    // Verify ConstrainedBox enforces full viewport minHeight for centering
    final constrainedBoxFinder = find.byWidgetPredicate(
      (widget) => widget is ConstrainedBox && widget.constraints.minHeight == 844.0,
    );
    expect(constrainedBoxFinder, findsOneWidget);
  });

  testWidgets('NeuralInferenceLoader renders on desktop viewport with flow view', (WidgetTester tester) async {
    // Set desktop viewport
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NeuralInferenceLoader(
            title: 'Initializing AI Compute Cluster',
            subtitle: 'Provisioning multi-agent workflow',
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    // Verify desktop header
    expect(find.text('EDU-TECH AI COMPUTE CLUSTER  •  NEURAL INFERENCE'), findsOneWidget);
    expect(find.text('Initializing AI Compute Cluster'), findsOneWidget);

    // Verify CustomPaint with NeuralNetworkPainter is present
    final customPaintFinder = find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is NeuralNetworkPainter,
    );
    expect(customPaintFinder, findsOneWidget);
  });
}
