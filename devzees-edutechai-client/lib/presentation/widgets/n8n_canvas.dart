import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import '../../core/constants/responsive.dart';

/// Ultra-premium, responsive DAG Blackboard Canvas.
///
/// Features:
/// - Fits 100% inside container boundaries on all screen breakpoints (no awkward 2D pan trap).
/// - Desktop (>= 720px): Multi-tier DAG architecture with central shared blackboard hub,
///   branching into parallel neural specialists, converging into formative evaluation and streaming.
/// - Mobile (< 720px): Vertical connected pipeline with glowing vertical energy wires.
/// - Live animated data-packet pulses traveling continuously along DAG wires.
/// - Breathing central blackboard core with telemetry indicators.
class N8nCanvas extends StatefulWidget {
  const N8nCanvas({super.key});

  @override
  State<N8nCanvas> createState() => _N8nCanvasState();
}

class _N8nCanvasState extends State<N8nCanvas> with TickerProviderStateMixin {
  late final AnimationController _flowController;
  late final AnimationController _pulseController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    // Flow animation for glowing data packets along the DAG bus lines
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    // Breathing pulse for Blackboard hub and container glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _glowAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _flowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isCompact = screenWidth < 740;
    final bool isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ─── 1. Header Badge (Outside Canvas Box) ───
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2B68F6).withValues(alpha: 0.14),
            border: Border.all(
              color: const Color(0xFF2B68F6).withValues(alpha: 0.38),
            ),
            borderRadius: BorderRadius.circular(9999),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B68F6).withValues(alpha: 0.25),
                blurRadius: 14,
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00F5D4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F5D4).withValues(alpha: 0.8),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'AUTONOMOUS MULTI-AGENT BLACKBOARD ARCHITECTURE',
                  style: TextStyle(
                    color: Color(0xFFDDD6FE),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // ─── 2. Section Title (Outside Canvas Box) ───
        GradientText(
          'Interactive Cognitive DAG Pipeline',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),

        // ─── 3. Section Subtitle (Outside Canvas Box) ───
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Text(
            'Deterministic Topic Ingestion ➔ Supervisor Topological DAG ➔ Shared Blackboard Memory ➔ Parallel Workers ➔ Formative Assessment ➔ Stream',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF94A3B8),
              fontSize: isMobile ? 13 : 15,
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 36),

        // ─── 4. Interactive Blackboard Canvas Box ───
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            final t = _glowAnimation.value;
            final borderColor = Color.lerp(
              AppColors.primary.withValues(alpha: 0.35),
              const Color(0xFF6B47EB).withValues(alpha: 0.55),
              t,
            )!;

            final outerShadow = BoxShadow(
              color: const Color(
                0xFF3B82F6,
              ).withValues(alpha: 0.12 + (0.08 * t)),
              blurRadius: 50 + (10 * t),
              spreadRadius: -10,
              offset: const Offset(0, 16),
            );

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF080B18),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: isMobile ? null : [outerShadow],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Ambient Radial Gradient behind Blackboard
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.85,
                            colors: [
                              const Color(
                                0xFF3B82F6,
                              ).withValues(alpha: 0.08 + (0.04 * t)),
                              const Color(0xFF6B47EB).withValues(alpha: 0.04),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Cyber Dot Grid Pattern
                    Positioned.fill(
                      child: CustomPaint(painter: _DotGridPainter()),
                    ),

                    // Canvas Content
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 28,
                        vertical: isMobile ? 24 : 36,
                      ),
                      child: isCompact
                          ? _buildMobileVerticalPipeline(t)
                          : _buildDesktopDagFlow(t),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // DESKTOP MULTI-TIER DAG GRAPH (Fits cleanly inside 640px width)
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildDesktopDagFlow(double pulseVal) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ─── LEVEL 1: Planning (Ingestion ──➔ Orchestrator) ───
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIngestionNode(compact: false),
                _AnimatedHorizontalWire(
                  animation: _flowController,
                  width: 44,
                  accentColor: AppColors.accentCyan,
                ),
                _buildOrchestratorNode(compact: false),
              ],
            ),

            // Wire down into Central Blackboard
            _AnimatedVerticalWire(
              animation: _flowController,
              height: 32,
              accentColor: AppColors.primary,
            ),

            // ─── LEVEL 2: Central Blackboard Memory Hub ───
            _buildBlackboardNode(pulseVal: pulseVal, compact: false),

            // Forking branches into 3 Parallel Workers
            SizedBox(
              width: 624,
              height: 38,
              child: CustomPaint(
                painter: _ForkBranchesPainter(
                  flowProgress: _flowController.value,
                  accentColor: const Color(0xFF6B47EB),
                ),
              ),
            ),

            // ─── LEVEL 3: 3 Parallel Neural Workers (Side-by-Side) ───
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWorkerCard(
                  icon: Icons.forum_rounded,
                  title: 'Socratic Tutor',
                  subtitle: 'Active Dialogue & Scaffolding',
                  tag: 'PEDAGOGY',
                  color: AppColors.primary,
                  width: 200,
                ),
                const SizedBox(width: 12),
                _buildWorkerCard(
                  icon: Icons.smart_display_rounded,
                  title: 'YouTube Curator',
                  subtitle: 'Transcript Vector Clips',
                  tag: 'CHROMADB',
                  color: AppColors.accentCyan,
                  width: 200,
                ),
                const SizedBox(width: 12),
                _buildWorkerCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Academic Scout',
                  subtitle: 'arXiv & OpenAlex DOIs',
                  tag: '250M+ PAPERS',
                  color: AppColors.accentGreen,
                  width: 200,
                ),
              ],
            ),

            // Converging branches from 3 Workers into Quiz Agent
            SizedBox(
              width: 624,
              height: 38,
              child: CustomPaint(
                painter: _ConvergeBranchesPainter(
                  flowProgress: _flowController.value,
                  accentColor: AppColors.accentAmber,
                ),
              ),
            ),

            // ─── LEVEL 4: Assessment & Delivery (Quiz ──➔ Synthesizer) ───
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuizNode(compact: false),
                _AnimatedHorizontalWire(
                  animation: _flowController,
                  width: 44,
                  accentColor: AppColors.accentAmber,
                ),
                _buildSynthesizerNode(compact: false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // MOBILE VERTICAL CONNECTED PIPELINE (Natural top-to-bottom reading)
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildMobileVerticalPipeline(double pulseVal) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          children: [
            // Stage 1: Ingestion
            _buildIngestionNode(compact: true),
            _AnimatedVerticalWire(
              animation: _flowController,
              height: 28,
              accentColor: AppColors.accentCyan,
            ),

            // Stage 2: Orchestrator
            _buildOrchestratorNode(compact: true),
            _AnimatedVerticalWire(
              animation: _flowController,
              height: 28,
              accentColor: AppColors.primary,
            ),

            // Stage 3: Blackboard
            _buildBlackboardNode(pulseVal: pulseVal, compact: true),
            _AnimatedVerticalWire(
              animation: _flowController,
              height: 28,
              accentColor: const Color(0xFF6B47EB),
            ),

            // Stage 4: Parallel Squad Cards (Stack)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00F5D4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'PARALLEL WORKER BRANCHES',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF00F5D4),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '3 IN PARALLEL',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildWorkerCard(
                    icon: Icons.forum_rounded,
                    title: 'Socratic Tutor',
                    subtitle: 'Active Dialogue & Scaffolding',
                    tag: 'PEDAGOGY',
                    color: AppColors.primary,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 8),
                  _buildWorkerCard(
                    icon: Icons.smart_display_rounded,
                    title: 'YouTube Curator',
                    subtitle: 'Transcript Vector Clips',
                    tag: 'CHROMADB',
                    color: AppColors.accentCyan,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 8),
                  _buildWorkerCard(
                    icon: Icons.menu_book_rounded,
                    title: 'Academic Scout',
                    subtitle: 'arXiv & OpenAlex DOIs',
                    tag: '250M+ PAPERS',
                    color: AppColors.accentGreen,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
            _AnimatedVerticalWire(
              animation: _flowController,
              height: 28,
              accentColor: AppColors.accentAmber,
            ),

            // Stage 5: Quiz Agent
            _buildQuizNode(compact: true),
            _AnimatedVerticalWire(
              animation: _flowController,
              height: 28,
              accentColor: AppColors.accentAmber,
            ),

            // Stage 6: Synthesizer
            _buildSynthesizerNode(compact: true),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // NODE BUILDERS WITH TACTILE DESIGN & TELEMETRY
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildIngestionNode({required bool compact}) {
    return _DagCard(
      width: compact ? double.infinity : 190,
      accentColor: AppColors.accentCyan,
      child: Row(
        mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
        children: [
          _NodeIconBadge(
            icon: Icons.track_changes_rounded,
            color: AppColors.accentCyan,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusBadge(text: 'TRIGGER', color: AppColors.accentCyan),
                const SizedBox(height: 3),
                const Text(
                  'Student Ingestion',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Topic • Mode • Level',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrchestratorNode({required bool compact}) {
    return _DagCard(
      width: compact ? double.infinity : 240,
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _NodeIconBadge(
                icon: Icons.account_tree_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusBadge(
                      text: 'DETERMINISTIC',
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'AI Orchestrator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Supervisor Agent',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF060914),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Text(
              '• Decomposes 4-7 Milestones\n• Auto-Detects Prerequisite Gaps\n• Topologically Ordered Plan',
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 9.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlackboardNode({
    required double pulseVal,
    required bool compact,
  }) {
    final borderColor = Color.lerp(
      const Color(0xFF6B47EB).withValues(alpha: 0.6),
      const Color(0xFFB838EE).withValues(alpha: 0.8),
      pulseVal,
    )!;

    return Container(
      width: compact ? double.infinity : 280,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xEE0B0E24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF6B47EB,
            ).withValues(alpha: 0.25 + (0.15 * pulseVal)),
            blurRadius: 20 + (10 * pulseVal),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B47EB), Color(0xFF2B68F6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B47EB).withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.memory_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusBadge(
                      text: 'CENTRAL HUB',
                      color: const Color(0xFFA855F7),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Shared Blackboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Central Memory State Bus',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF6B47EB).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF6B47EB).withValues(alpha: 0.3),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00F5D4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Zero Agent-to-Agent Mesh (O(N) Bus)',
                    style: TextStyle(
                      color: Color(0xFFDDD6FE),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String tag,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xDD0A0D1D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusBadge(text: tag, color: color),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizNode({required bool compact}) {
    return _DagCard(
      width: compact ? double.infinity : 190,
      accentColor: AppColors.accentAmber,
      child: Row(
        mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
        children: [
          _NodeIconBadge(
            icon: Icons.fact_check_rounded,
            color: AppColors.accentAmber,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusBadge(text: 'EVALUATING', color: AppColors.accentAmber),
                const SizedBox(height: 3),
                const Text(
                  'Quiz Agent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Grounded Assessment',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynthesizerNode({required bool compact}) {
    return _DagCard(
      width: compact ? double.infinity : 200,
      accentColor: AppColors.accentPink,
      child: Row(
        mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
        children: [
          _NodeIconBadge(icon: Icons.bolt_rounded, color: AppColors.accentPink),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusBadge(text: 'STREAMING', color: AppColors.accentPink),
                const SizedBox(height: 3),
                const Text(
                  'Synthesizer Agent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Obsidian • PDF • Stream',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// REUSABLE MICRO-COMPONENTS
// ═════════════════════════════════════════════════════════════════════════════

class _DagCard extends StatelessWidget {
  final double width;
  final Color accentColor;
  final Widget child;

  const _DagCard({
    required this.width,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xDD0A0D1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.40),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _NodeIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _NodeIconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8),
        ],
      ),
      child: Icon(icon, color: color, size: 17),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [BoxShadow(color: color, blurRadius: 4)],
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ANIMATED WIRE & BRANCH PAINTERS (Flowing data packet pulses)
// ═════════════════════════════════════════════════════════════════════════════

class _AnimatedHorizontalWire extends StatelessWidget {
  final Animation<double> animation;
  final double width;
  final Color accentColor;

  const _AnimatedHorizontalWire({
    required this.animation,
    required this.width,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 24,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return CustomPaint(
            painter: _HorizontalWirePainter(
              progress: animation.value,
              accentColor: accentColor,
            ),
          );
        },
      ),
    );
  }
}

class _HorizontalWirePainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  _HorizontalWirePainter({required this.progress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), trackPaint);

    // Glowing Pulse
    final pulsePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final pulseLength = size.width * 0.4;
    final pulseStart = (size.width + pulseLength) * progress - pulseLength;
    final pulseEnd = (pulseStart + pulseLength).clamp(0.0, size.width);
    if (pulseEnd > pulseStart && pulseStart < size.width) {
      canvas.drawLine(
        Offset(pulseStart.clamp(0.0, size.width), y),
        Offset(pulseEnd, y),
        pulsePaint,
      );
    }

    // Moving Data Packet Dot
    final packetX = size.width * progress;
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(packetX, y), 5.0, glowPaint);
    canvas.drawCircle(Offset(packetX, y), 2.5, dotPaint);

    // End Ports
    _drawPort(canvas, Offset(0, y), accentColor);
    _drawPort(canvas, Offset(size.width, y), accentColor);
  }

  void _drawPort(Canvas canvas, Offset offset, Color color) {
    final portPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFF080B18)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(offset, 4.0, portPaint);
    canvas.drawCircle(offset, 4.0, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _HorizontalWirePainter oldDelegate) => true;
}

class _AnimatedVerticalWire extends StatelessWidget {
  final Animation<double> animation;
  final double height;
  final Color accentColor;

  const _AnimatedVerticalWire({
    required this.animation,
    required this.height,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: height,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return CustomPaint(
            painter: _VerticalWirePainter(
              progress: animation.value,
              accentColor: accentColor,
            ),
          );
        },
      ),
    );
  }
}

class _VerticalWirePainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  _VerticalWirePainter({required this.progress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), trackPaint);

    // Glowing Pulse
    final pulsePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final pulseLength = size.height * 0.4;
    final pulseStart = (size.height + pulseLength) * progress - pulseLength;
    final pulseEnd = (pulseStart + pulseLength).clamp(0.0, size.height);
    if (pulseEnd > pulseStart && pulseStart < size.height) {
      canvas.drawLine(
        Offset(x, pulseStart.clamp(0.0, size.height)),
        Offset(x, pulseEnd),
        pulsePaint,
      );
    }

    // Moving Data Packet Dot
    final packetY = size.height * progress;
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(x, packetY), 5.0, glowPaint);
    canvas.drawCircle(Offset(x, packetY), 2.5, dotPaint);

    // Ports
    _drawPort(canvas, Offset(x, 0), accentColor);
    _drawPort(canvas, Offset(x, size.height), accentColor);
  }

  void _drawPort(Canvas canvas, Offset offset, Color color) {
    final portPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFF080B18)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(offset, 4.0, portPaint);
    canvas.drawCircle(offset, 4.0, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _VerticalWirePainter oldDelegate) => true;
}

/// Draws 3 curved bezier branches forking out from Blackboard down into the 3 worker nodes.
class _ForkBranchesPainter extends CustomPainter {
  final double flowProgress;
  final Color accentColor;

  _ForkBranchesPainter({required this.flowProgress, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const startY = 0.0;
    final endY = size.height;

    // Target X coordinates for the 3 worker columns
    final targetXs = [
      size.width * 0.16, // Left Worker (Socratic)
      centerX, // Middle Worker (YouTube)
      size.width * 0.84, // Right Worker (Academic)
    ];

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final targetX in targetXs) {
      final path = Path()
        ..moveTo(centerX, startY)
        ..cubicTo(
          centerX,
          size.height * 0.5,
          targetX,
          size.height * 0.5,
          targetX,
          endY,
        );

      canvas.drawPath(path, trackPaint);

      // Draw flowing packet along the curve
      final metrics = path.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        final distance = metric.length * flowProgress;
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 4.5, glowPaint);
          canvas.drawCircle(tangent.position, 2.2, dotPaint);
        }
      }
    }

    // Top port
    canvas.drawCircle(
      Offset(centerX, startY),
      3.5,
      Paint()..color = accentColor,
    );
  }

  @override
  bool shouldRepaint(covariant _ForkBranchesPainter oldDelegate) => true;
}

/// Draws 3 curved bezier branches converging from the 3 worker nodes down into the Quiz node.
class _ConvergeBranchesPainter extends CustomPainter {
  final double flowProgress;
  final Color accentColor;

  _ConvergeBranchesPainter({
    required this.flowProgress,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const startY = 0.0;
    final endY = size.height;

    final sourceXs = [
      size.width * 0.17, // Left Worker
      centerX, // Middle Worker
      size.width * 0.83, // Right Worker
    ];

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final sourceX in sourceXs) {
      final path = Path()
        ..moveTo(sourceX, startY)
        ..cubicTo(
          sourceX,
          size.height * 0.5,
          centerX,
          size.height * 0.5,
          centerX,
          endY,
        );

      canvas.drawPath(path, trackPaint);

      // Flowing packet
      final metrics = path.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        final distance = metric.length * flowProgress;
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 4.5, glowPaint);
          canvas.drawCircle(tangent.position, 2.2, dotPaint);
        }
      }
    }

    // Bottom port
    canvas.drawCircle(Offset(centerX, endY), 3.5, Paint()..color = accentColor);
  }

  @override
  bool shouldRepaint(covariant _ConvergeBranchesPainter oldDelegate) => true;
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    const double spacing = 22.0;
    const double radius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
