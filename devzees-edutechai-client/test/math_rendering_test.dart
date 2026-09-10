import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathBlockItem {
  final bool isMath;
  final String content;
  final bool isDisplay;

  MathBlockItem({
    required this.isMath,
    required this.content,
    this.isDisplay = true,
  });
}

List<MathBlockItem> parseContentWithMath(String rawText) {
  final items = <MathBlockItem>[];

  // Regex to match display math:
  // 1. [ \begin{...} ... \end{...} ] or \[ \begin{...} ... \end{...} \]
  // 2. $$ ... $$
  // 3. \[ ... \]
  // 4. ```math ... ``` or ```latex ... ```
  final blockMathRegex = RegExp(
    r'(?:(?:\\\[|\[)\s*(\\begin\{(?:aligned|matrix|bmatrix|pmatrix|vmatrix|cases|gather|equation)\b[\s\S]+?\\end\{(?:aligned|matrix|bmatrix|pmatrix|vmatrix|cases|gather|equation)\})\s*(?:\\\]|\]))'
    r'|'
    r'(?:\$\$([\s\S]+?)\$\$)'
    r'|'
    r'(?:\\\[([\s\S]+?)\\\])'
    r'|'
    r'(?:```(?:math|latex)\s*([\s\S]+?)```)',
    multiLine: true,
  );

  int lastIndex = 0;

  for (final match in blockMathRegex.allMatches(rawText)) {
    if (match.start > lastIndex) {
      final markdownPart = rawText.substring(lastIndex, match.start).trim();
      if (markdownPart.isNotEmpty) {
        items.add(MathBlockItem(isMath: false, content: markdownPart));
      }
    }

    final mathTex = (match.group(1) ?? match.group(2) ?? match.group(3) ?? match.group(4) ?? '').trim();
    if (mathTex.isNotEmpty) {
      items.add(MathBlockItem(isMath: true, content: mathTex, isDisplay: true));
    }

    lastIndex = match.end;
  }

  if (lastIndex < rawText.length) {
    final remaining = rawText.substring(lastIndex).trim();
    if (remaining.isNotEmpty) {
      items.add(MathBlockItem(isMath: false, content: remaining));
    }
  }

  return items;
}

String sanitizeMathTex(String rawTex) {
  var clean = rawTex.trim();
  // Remove unnecessary \! (negative thin space) that AI tutors often generate
  clean = clean.replaceAll(r'\!', '');
  // Normalize unescaped newline delimiters: ', \ ' or ', \' -> ' \\ '
  clean = clean.replaceAll(RegExp(r',\s*\\\s*'), r' \\ ');
  // Split multiple equations per line '& ... & ...' or ', &' into separate rows '\\'
  // to avoid multi-column EqnArray width calculation assertions in Flutter
  clean = clean.replaceAll(RegExp(r',\s*&\s*'), r' \\ ');
  return clean;
}

Widget buildMathCard(String tex) {
  final cleanTex = sanitizeMathTex(tex);
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFF130D21),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: const Color(0xFFA855F7).withValues(alpha: 0.35),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFA855F7).withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Math.tex(
        cleanTex,
        mathStyle: MathStyle.display,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
        onErrorFallback: (err) => Text(
          cleanTex,
          style: const TextStyle(
            color: Color(0xFFE9D5FF),
            fontFamily: 'monospace',
            fontSize: 13,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('test single equation', (WidgetTester tester) async {
    const tex = r'\nabla\cdot\mathbf{E} = \frac{\rho}{\varepsilon_0}';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Math.tex(tex),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Math), findsOneWidget);
  });

  testWidgets('test aligned with single &', (WidgetTester tester) async {
    const tex = r'''\begin{aligned}
\nabla\cdot\mathbf{E} &= \frac{\rho}{\varepsilon_0} \\
\nabla\cdot\mathbf{B} &= 0 \\
\nabla\times\mathbf{E} &= -\frac{\partial\mathbf{B}}{\partial t} \\
\nabla\times\mathbf{B} &= \mu_0\mathbf{J}+\mu_0\varepsilon_0\frac{\partial\mathbf{E}}{\partial t}
\end{aligned}''';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Math.tex(tex),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Math), findsOneWidget);
  });

  testWidgets('test sanitized TeX in Column', (WidgetTester tester) async {
    // Original raw TeX that caused the error:
    final rawTex = r'''\begin{aligned} \nabla!\cdot!\mathbf{E} &= \frac{\rho}{\varepsilon_0}, & \nabla!\cdot!\mathbf{B} &= 0, \ \nabla\times!\mathbf{E} &= -\frac{\partial\mathbf{B}}{\partial t}, & \nabla\times!\mathbf{B} &= \mu_0\mathbf{J}+\mu_0\varepsilon_0\frac{\partial\mathbf{E}}{\partial t}. \end{aligned}''';

    // Normalize:
    // 1. Remove unnecessary \! that LLM puts in dot/cross products
    // 2. Turn unescaped newline ', \ ' or ', \' into ' \\ '
    // 3. Split multiple equations per line '& ... & ...' into separate lines '\\'
    var cleanTex = rawTex
        .replaceAll(r'\!', '')
        .replaceAll(RegExp(r',\s*\\\s*'), r' \\ ')
        .replaceAll(RegExp(r',\s*&\s*'), r' \\ ');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Math.tex(
                  cleanTex,
                  mathStyle: MathStyle.display,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Math), findsOneWidget);
  });

  testWidgets('parseContentWithMath full flow', (WidgetTester tester) async {
    const rawAiResponse = '''
Maxwell’s equations, expressed in differential form, compactly encode how electric and magnetic fields evolve and interact with sources:

[ \\begin{aligned} \\nabla!\\cdot!\\mathbf{E} &= \\frac{\\rho}{\\varepsilon_0}, & \\nabla!\\cdot!\\mathbf{B} &= 0, \\ \\nabla\\times!\\mathbf{E} &= -\\frac{\\partial\\mathbf{B}}{\\partial t}, & \\nabla\\times!\\mathbf{B} &= \\mu_0\\mathbf{J}+\\mu_0\\varepsilon_0\\frac{\\partial\\mathbf{E}}{\\partial t}. \\end{aligned} ]

These equations form the foundation of classical electromagnetism.
''';

    final blocks = parseContentWithMath(rawAiResponse);
    expect(blocks.length, 3);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final b in blocks)
                  if (b.isMath)
                    buildMathCard(sanitizeMathTex(b.content))
                  else
                    MarkdownBody(data: b.content),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Math), findsNWidgets(1));
    expect(find.byType(MarkdownBody), findsNWidgets(2));
  });

  testWidgets('handles various math block formats', (WidgetTester tester) async {
    const rawAiResponse = '''
Here is Newton's second law:
\$\$ F = m \\cdot a \$\$
And here is Einstein's energy-mass relation:
\\[ E = mc^2 \\]
And a math code block:
```math
\\int_{0}^{\\infty} e^{-x^2} dx = \\frac{\\sqrt{\\pi}}{2}
```
All together!
''';

    final blocks = parseContentWithMath(rawAiResponse);
    expect(blocks.length, 7);
    expect(blocks[0].isMath, isFalse);
    expect(blocks[1].isMath, isTrue);
    expect(blocks[1].content, r'F = m \cdot a');
    expect(blocks[2].isMath, isFalse);
    expect(blocks[3].isMath, isTrue);
    expect(blocks[3].content, r'E = mc^2');
    expect(blocks[4].isMath, isFalse);
    expect(blocks[5].isMath, isTrue);
    expect(blocks[5].content, r'\int_{0}^{\infty} e^{-x^2} dx = \frac{\sqrt{\pi}}{2}');
    expect(blocks[6].isMath, isFalse);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: blocks.map((b) => b.isMath ? buildMathCard(b.content) : Text(b.content)).toList(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Math), findsNWidgets(3));
  });
}
