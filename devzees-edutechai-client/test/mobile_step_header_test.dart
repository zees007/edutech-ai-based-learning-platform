import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/data/models/learning/milestone_step.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/main_content/neural_inference_loader.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/workspace/milestone_roadmap_stepper.dart';
import 'package:devzees_edutechai_client/presentation/widgets/animated_tutor_icon.dart';

void main() {
  group('Mobile Step Header Logic & UI tests', () {
    Widget buildHeaderHarness({
      required int stepIndex,
      required int totalSteps,
      required int maxUnlockedIndex,
      required String stepStatus,
      required int stepsCompleted,
      required ValueChanged<int> onStepChange,
      required VoidCallback onRegenerate,
      bool isRegenerating = false,
    }) {
      final bool isLastStep = totalSteps > 0 && stepIndex >= totalSteps - 1;
      final bool isSessionComplete = totalSteps > 0 && stepsCompleted >= totalSteps;
      final bool isCurrentStepComplete = stepStatus == 'complete' ||
          (isLastStep && isSessionComplete) ||
          (stepIndex < stepsCompleted);
      final bool isReviewing = stepIndex < maxUnlockedIndex || isCurrentStepComplete;
      final bool canGoBack = stepIndex > 0;
      final bool canGoForward = stepIndex < totalSteps - 1 &&
          (isCurrentStepComplete || stepIndex < maxUnlockedIndex);

      return MaterialApp(
        home: Scaffold(
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surfaceSolidHeader,
            ),
            child: Row(
              children: [
                if (canGoBack) ...[
                  Tooltip(
                    message: 'Go back to Step $stepIndex',
                    child: GestureDetector(
                      key: const Key('btn_prev'),
                      onTap: () => onStepChange(stepIndex - 1),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Step pill
                Container(
                  key: const Key('step_pill'),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: Text('Step ${stepIndex + 1}/$totalSteps'),
                ),
                const SizedBox(width: 10),
                // Title
                const Expanded(
                  child: Text('Test Step Title'),
                ),
                // Trailing end
                if (!isCurrentStepComplete) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Regenerate Step ${stepIndex + 1}',
                    child: GestureDetector(
                      key: const Key('btn_regen'),
                      onTap: isRegenerating ? null : onRegenerate,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          gradient: AppColors.royalBlueIndigoGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else if (canGoForward) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Go forward to Step ${stepIndex + 2}',
                    child: GestureDetector(
                      key: const Key('btn_next'),
                      onTap: () => onStepChange(stepIndex + 1),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.glassBase,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    testWidgets('Uncompleted step 0: shows regenerate icon with royalBlueIndigoGradient, no back, no forward', (tester) async {
      int stepChangeCall = -1;
      bool regenCalled = false;

      await tester.pumpWidget(
        buildHeaderHarness(
          stepIndex: 0,
          totalSteps: 3,
          maxUnlockedIndex: 0,
          stepStatus: 'in_progress',
          stepsCompleted: 0,
          onStepChange: (index) => stepChangeCall = index,
          onRegenerate: () => regenCalled = true,
        ),
      );

      expect(find.byKey(const Key('btn_prev')), findsNothing);
      expect(find.byKey(const Key('btn_next')), findsNothing);
      expect(find.byKey(const Key('btn_regen')), findsOneWidget);

      // Verify gradient decoration on regenerate button
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const Key('btn_regen')),
          matching: find.byType(Container),
        ),
      );
      final boxDec = container.decoration as BoxDecoration;
      expect(boxDec.gradient, equals(AppColors.royalBlueIndigoGradient));

      // Tap regenerate
      await tester.tap(find.byKey(const Key('btn_regen')));
      expect(regenCalled, isTrue);
      expect(stepChangeCall, equals(-1));
    });

    testWidgets('Completed step 0: shows go forward icon at trailing end, no regen, no back', (tester) async {
      int stepChangeCall = -1;
      bool regenCalled = false;

      await tester.pumpWidget(
        buildHeaderHarness(
          stepIndex: 0,
          totalSteps: 3,
          maxUnlockedIndex: 1,
          stepStatus: 'complete',
          stepsCompleted: 1,
          onStepChange: (index) => stepChangeCall = index,
          onRegenerate: () => regenCalled = true,
        ),
      );

      expect(find.byKey(const Key('btn_prev')), findsNothing);
      expect(find.byKey(const Key('btn_regen')), findsNothing);
      expect(find.byKey(const Key('btn_next')), findsOneWidget);

      await tester.tap(find.byKey(const Key('btn_next')));
      expect(stepChangeCall, equals(1));
      expect(regenCalled, isFalse);
    });

    testWidgets('Reviewing step 1 of 3 (completed): shows both back and forward icons', (tester) async {
      int stepChangeCall = -1;

      await tester.pumpWidget(
        buildHeaderHarness(
          stepIndex: 1,
          totalSteps: 3,
          maxUnlockedIndex: 2,
          stepStatus: 'complete',
          stepsCompleted: 2,
          onStepChange: (index) => stepChangeCall = index,
          onRegenerate: () {},
        ),
      );

      expect(find.byKey(const Key('btn_prev')), findsOneWidget);
      expect(find.byKey(const Key('btn_next')), findsOneWidget);
      expect(find.byKey(const Key('btn_regen')), findsNothing);

      await tester.tap(find.byKey(const Key('btn_prev')));
      expect(stepChangeCall, equals(0));

      await tester.tap(find.byKey(const Key('btn_next')));
      expect(stepChangeCall, equals(2));
    });

    testWidgets('Final step (completed): shows back icon, neither forward nor regen', (tester) async {
      await tester.pumpWidget(
        buildHeaderHarness(
          stepIndex: 2,
          totalSteps: 3,
          maxUnlockedIndex: 2,
          stepStatus: 'complete',
          stepsCompleted: 3,
          onStepChange: (_) {},
          onRegenerate: () {},
        ),
      );

      expect(find.byKey(const Key('btn_prev')), findsOneWidget);
      expect(find.byKey(const Key('btn_next')), findsNothing);
      expect(find.byKey(const Key('btn_regen')), findsNothing);
    });

    testWidgets('NeuralInferenceLoader in mobile width renders AnimatedTutorIcon inside spinner', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeuralInferenceLoader(
              title: 'Synthesizing Step 2: CNNs',
              subtitle: 'Multi-Agents generating content...',
            ),
          ),
        ),
      );

      // Verify AnimatedTutorIcon is found in mobile view
      expect(find.byType(AnimatedTutorIcon), findsOneWidget);
      final tutorIcon = tester.widget<AnimatedTutorIcon>(find.byType(AnimatedTutorIcon));
      expect(tutorIcon.size, equals(34.0));
      expect(tutorIcon.showHalo, isFalse);
    });

    testWidgets('MilestoneRoadmapStepper in mobile width auto-scrolls to center active step cleanly without edge overlays', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final List<MilestoneStep> testSteps = List.generate(
        7,
        (i) => MilestoneStep(
          index: i,
          title: 'Step ${i + 1} Topic',
          description: 'Step ${i + 1} description',
          status: i < 3 ? 'complete' : 'in_progress',
        ),
      );

      // Pump with activeIndex = 0
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: MilestoneRoadmapStepper(
                steps: testSteps,
                activeIndex: 0,
                maxUnlockedIndex: 3,
                onStepTapped: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No edge chevron overlay icons should exist
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
      expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);

      // Now update activeIndex to 4 (Step 5)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: MilestoneRoadmapStepper(
                steps: testSteps,
                activeIndex: 4,
                maxUnlockedIndex: 4,
                onStepTapped: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Still no edge chevrons
      expect(find.byIcon(Icons.chevron_left_rounded), findsNothing);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);

      // Verify scroll offset moved past 200 to center Step 5
      final scrollable = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      expect(scrollable.controller!.offset, greaterThan(200.0));
    });
  });
}
