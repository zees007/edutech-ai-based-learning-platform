import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/data/models/learning/milestone_step.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/workspace/milestone_roadmap_stepper.dart';

void main() {
  testWidgets('MilestoneRoadmapStepper renders interlocking chevrons and handles taps', (WidgetTester tester) async {
    final steps = [
      MilestoneStep(
        index: 0,
        title: 'Quantum Superposition',
        description: 'Basics of qubits',
        status: 'complete',
      ),
      MilestoneStep(
        index: 1,
        title: 'Quantum Entanglement',
        description: 'Spooky action',
        status: 'in_progress',
      ),
      MilestoneStep(
        index: 2,
        title: 'Quantum Circuits',
        description: 'Building logic gates',
        status: 'pending',
      ),
    ];

    int tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 600,
              child: MilestoneRoadmapStepper(
                steps: steps,
                activeIndex: 1,
                maxUnlockedIndex: 1,
                onStepTapped: (index) {
                  tappedIndex = index;
                },
              ),
            ),
          ),
        ),
      ),
    );

    // Verify step labels are rendered
    expect(find.text('STEP 1'), findsOneWidget);
    expect(find.text('STEP 2'), findsOneWidget);
    expect(find.text('STEP 3'), findsOneWidget);

    // Verify status badges are rendered
    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('IN PROGRESS'), findsOneWidget);
    expect(find.text('LOCKED'), findsOneWidget);

    // Verify titles are rendered
    expect(find.text('Quantum Superposition'), findsOneWidget);
    expect(find.text('Quantum Entanglement'), findsOneWidget);
    expect(find.text('Quantum Circuits'), findsOneWidget);

    // Tap completed step (Step 0) -> should trigger callback
    await tester.tap(find.text('STEP 1'));
    expect(tappedIndex, 0);

    // Tap locked step (Step 2) -> should NOT trigger callback
    tappedIndex = -1;
    await tester.tap(find.text('STEP 3'));
    expect(tappedIndex, -1);
  });
}
