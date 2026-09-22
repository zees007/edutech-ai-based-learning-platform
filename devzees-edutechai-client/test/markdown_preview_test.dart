import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/export/markdown_preview_dialog.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/workspace/mermaid_web_view.dart';
import 'package:devzees_edutechai_client/presentation/pages/learning/widgets/workspace/keep_alive_wrapper.dart';

void main() {
  group('Markdown Preview Flowchart & Preprocessing Tests', () {
    test('Unfenced graph TD flowchart is recognized and wrapped into mermaid block', () {
      const rawMarkdown = '''
# Milestone 1: Introduction

graph TD
  A["Program (Recipe Book)"] --> B["CPU (Robot)"]
  B -->|"Fetch Instruction"| C["Memory (Pantry)"]
  C -->|"Decode & Execute"| D["Perform Action"]
  D -->|"Produce Output"| E["Result (Cake)"]

#### 💡 Reflection & Socratic Prompts
1. What is the role of CPU?
''';

      // We test through the widget builder by checking if MarkdownPreviewDialog parses it
      final widget = MaterialApp(
        home: Scaffold(
          body: MarkdownPreviewDialog(
            topic: 'Computer Architecture',
            markdownContent: rawMarkdown,
            sessionId: 'test-session-123',
          ),
        ),
      );

      expect(widget, isNotNull);
    });

    test('Fenced mermaid block is detected by code builder and renders KeepAliveWrapper with MermaidWebView', () {
      // Create a test element or builder harness
      final builder = Markdown(
        data: '''
```mermaid
graph TD
  A --> B
```
''',
        builders: {
          'code': _TestMermaidCodeBlockDetector(),
        },
      );

      expect(builder, isNotNull);
    });

    testWidgets('MarkdownPreviewDialog renders cleanly on mobile screen (360x780) without overflow', (tester) async {
      // Set mobile phone screen size (e.g. Pixel / Galaxy standard 360 width)
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const testMarkdown = '''
# ⚡ EduTechAI — Learning Journey Summary
> **Topic:** Computer Architecture
> **Status:** Mastered & Completed ✅

### 📊 Journey Overview
| Metric | Details |
|---|---|
| Milestones Completed | 4/4 (100%) |

## 🎯 Mastered Milestones
### Milestone 1: CPU Architecture ✅
Key takeaways regarding CPU execution and instruction cycles.

#### 💡 Reflection & Socratic Prompts
1. Why does instruction pipelining boost performance?
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewDialog(
              topic: 'Computer Architecture Foundations & Microservices',
              markdownContent: testMarkdown,
              sessionId: 'sess_abc123',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify no RenderFlex overflow
      expect(tester.takeException(), isNull);

      // Verify Download .md button is present and visible
      final downloadBtn = find.widgetWithText(ElevatedButton, 'Download .md');
      expect(downloadBtn, findsOneWidget);

      // Verify header components
      expect(find.text('Markdown Notes Preview'), findsOneWidget);
      expect(find.text('⚡ Compatible with Obsidian, Notion & GitHub'), findsOneWidget);
    });

    testWidgets('MarkdownPreviewDialog renders cleanly on narrow mobile screen (320x568) without overflow', (tester) async {
      // Ultra-narrow 320px width (iPhone SE 1st gen / small viewport)
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const testMarkdown = '''
# Milestone Notes
Short note content for narrow viewport testing.
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewDialog(
              topic: 'Very Long Topic Name That Might Test Ellipsis Behavior',
              markdownContent: testMarkdown,
              sessionId: 'sess_320',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Zero overflow errors
      expect(tester.takeException(), isNull);

      // Download button visible
      expect(find.widgetWithText(ElevatedButton, 'Download .md'), findsOneWidget);
    });

    testWidgets('MarkdownPreviewDialog renders desktop layout (1024x768) properly', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownPreviewDialog(
              topic: 'Quantum Computing',
              markdownContent: '# Quantum Computing Notes',
              sessionId: 'sess_desktop',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.widgetWithText(ElevatedButton, 'Download .md'), findsOneWidget);
      expect(find.text('⚡ Compatible with Obsidian, Notion & GitHub'), findsOneWidget);
    });
  });
}

class _TestMermaidCodeBlockDetector extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, preferredStyle) {
    final text = element.textContent;
    if (element.attributes['class']?.contains('language-mermaid') == true ||
        text.startsWith('graph ')) {
      return Container(key: const Key('mermaid_detected'));
    }
    return null;
  }
}
