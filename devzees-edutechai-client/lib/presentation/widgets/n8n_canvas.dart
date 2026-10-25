import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import '../../core/constants/responsive.dart';

class N8nCanvas extends StatefulWidget {
  const N8nCanvas({super.key});

  @override
  State<N8nCanvas> createState() => _N8nCanvasState();
}

class _N8nCanvasState extends State<N8nCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final t = _glowAnimation.value;
        final borderColor = Color.lerp(
          AppColors.primary.withValues(alpha: 0.35),
          AppColors.primary.withValues(alpha: 0.5),
          t,
        )!;

        final outerShadow = BoxShadow(
          color: AppColors.isDark
              ? AppColors.purpleDeep.withValues(alpha: 0.3 + (0.2 * t))
              : AppColors.primary.withValues(alpha: 0.08 + (0.05 * t)),
          blurRadius: 60 + (10 * t),
          spreadRadius: -15 + (5 * t),
          offset: const Offset(0, 20),
        );

        final innerShadow = BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.15 + (0.10 * t)),
          blurRadius: 30 + (10 * t),
          blurStyle: BlurStyle.inner,
        );

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.canvasBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: Responsive.isMobile(context) ? null : [outerShadow, innerShadow],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 40,
                    left: 20,
                    right: 20,
                    bottom: 24,
                  ),
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
      child: Column(
        children: [
          // Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: Responsive.isMobile(context)
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                      ),
                    ],
            ),
            child: Text(
              '⚡ AUTONOMOUS MULTI-AGENT BLACKBOARD ARCHITECTURE',
              style: TextStyle(
                color: AppColors.adaptiveLavender,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Interactive DAG Pipeline: Topic Ingestion ➔ Supervisor Planning ➔ Shared Blackboard ➔ Parallel Workers ➔ Assessment ➔ Streaming',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 36),

          // Interactive Diagram Canvas
          SizedBox(
            height: 400,
            width: double.infinity,
            child: InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(80),
              minScale: 0.1,
              maxScale: 3.0,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 120,
                  left: 24,
                  right: 24,
                  top: 30,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTriggerNode(),
                    const _Wire(),
                    _buildOrchestratorNode(),
                    const _Wire(),
                    _buildSharedMemoryNode(),
                    const _Wire(),
                    _buildWorkerBranches(),
                    const _Wire(),
                    _buildQuizNode(),
                    const _Wire(),
                    _buildSynthesizerNode(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerNode() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentCyan.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: Responsive.isMobile(context)
            ? null
            : [
                BoxShadow(
                  color: AppColors.accentCyan.withValues(alpha: 0.2),
                  blurRadius: 15,
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentCyan),
            ),
            child: const Center(child: Text('🎯', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Student Ingestion',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Topic + Mode + Level',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrchestratorNode() {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: Responsive.isMobile(context)
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 25,
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Orchestrator',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Supervisor Agent',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              '• Decomposes 4-7 Milestones\n• Auto-Detects Prerequisite Gap\n• Writes Learning Plan',
              style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedMemoryNode() {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentPurple.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: Responsive.isMobile(context)
            ? null
            : [
                BoxShadow(
                  color: AppColors.accentPurple.withValues(alpha: 0.25),
                  blurRadius: 25,
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentPurple),
            ),
            child: const Center(child: Text('🧠', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(height: 8),
          Text(
            'SharedMemory',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Central Blackboard State',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Zero Agent-to-Agent Mesh',
              style: TextStyle(color: AppColors.accentPurple, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerBranches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWorkerCard(
          icon: '💬',
          title: 'Socratic Tutor',
          subtitle: 'Pedagogy & Mermaid Diagrams',
          color: AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildWorkerCard(
          icon: '🎬',
          title: 'YouTube Curator',
          subtitle: 'Transcript Vector Deep-Linking',
          color: AppColors.accentCyan,
        ),
        const SizedBox(height: 12),
        _buildWorkerCard(
          icon: '📚',
          title: 'Academic Researcher',
          subtitle: 'arXiv & OpenAlex Preprints',
          color: AppColors.accentGreen,
        ),
      ],
    );
  }

  Widget _buildWorkerCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 9),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizNode() {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accentAmber.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: Responsive.isMobile(context)
            ? null
            : [
                BoxShadow(
                  color: AppColors.accentAmber.withValues(alpha: 0.2),
                  blurRadius: 20,
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentAmber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentAmber),
            ),
            child: const Center(child: Text('📝', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(height: 8),
          Text(
            'Quiz Agent',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Grounded Assessment',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 6),
          const Text(
            'Derived from Tutor Output',
            style: TextStyle(color: AppColors.accentAmber, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSynthesizerNode() {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMid.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accentPink.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: Responsive.isMobile(context)
            ? null
            : [
                BoxShadow(
                  color: AppColors.accentPink.withValues(alpha: 0.25),
                  blurRadius: 20,
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentPink.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentPink),
            ),
            child: const Center(child: Text('⚡', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(height: 8),
          Text(
            'Synthesizer Agent',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'WebSocket Streamer',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.accentPink.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Sub-Second UI Reactive',
              style: TextStyle(color: AppColors.accentPink, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _Wire extends StatelessWidget {
  const _Wire();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPort(),
        Container(
          width: 28,
          height: 3,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            boxShadow: Responsive.isMobile(context)
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
          ),
        ),
        _buildPort(),
      ],
    );
  }

  Widget _buildPort() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.purpleLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceDark, width: 1.5),
        boxShadow: const [
          BoxShadow(color: AppColors.purpleLight, blurRadius: 6),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.05);
    const double spacing = 20.0;
    const double radius = 1.2;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
