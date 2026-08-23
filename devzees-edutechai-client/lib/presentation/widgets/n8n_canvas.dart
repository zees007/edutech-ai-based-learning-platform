import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';

class N8nCanvas extends StatefulWidget {
  const N8nCanvas({Key? key}) : super(key: key);

  @override
  State<N8nCanvas> createState() => _N8nCanvasState();
}

class _N8nCanvasState extends State<N8nCanvas> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _glowAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
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
          color: const Color(0xFF7C3AED).withValues(alpha: 0.3 + (0.2 * t)),
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
            color: const Color(0xFF0B0813),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [outerShadow, innerShadow],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const FractionalOffset(0.2, 0.3),
                        radius: 0.8,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.8],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const FractionalOffset(0.8, 0.7),
                        radius: 0.8,
                        colors: [
                          AppColors.accentBlue.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.8],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(painter: _DotGridPainter()),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 24),
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16),
              ],
            ),
            child: const Text(
              '⚡ EDUTECH AI — AUTONOMOUS MULTI-AGENT FLOW',
              style: TextStyle(
                color: Color(0xFFE9D5FF),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
          
          // Diagram
          SizedBox(
            height: 350,
            width: double.infinity,
            child: InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(80),
              minScale: 0.1,
              maxScale: 3.0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120, left: 16, right: 16, top: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildTriggerNode(),
                    const _Wire(),
                    _buildOrchestratorNode(),
                    const _Wire(),
                    _buildDecisionNode(),
                    const SizedBox(width: 8),
                    _buildBranches(),
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
      padding: const EdgeInsets.only(left: 10, right: 18, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          bottomLeft: Radius.circular(40),
          topRight: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 4)),
          BoxShadow(color: AppColors.accentCyan.withValues(alpha: 0.25), blurRadius: 15),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚡', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
          const SizedBox(width: 4),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.5)),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.accentCyan.withValues(alpha: 0.3), blurRadius: 12)],
            ),
            child: const Center(child: Text('📝', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 10),
          const SizedBox(
            width: 110,
            child: Text(
              "On 'Topic Selection' submission",
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrchestratorNode() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 30),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12)],
                    ),
                    child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Orchestrator', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                      Text('Multi-Agent Supervisor', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Model*', style: TextStyle(color: Colors.white54, fontSize: 9)),
                    Text('Memory', style: TextStyle(color: Colors.white54, fontSize: 9)),
                    Text('Tools', style: TextStyle(color: Colors.white54, fontSize: 9)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Sub-nodes group
        Positioned(
          top: 105,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSubNode('✨', 'Google Gemini'),
              const SizedBox(width: 16),
              _buildSubNode('🐘', 'PostgreSQL DB'),
              const SizedBox(width: 16),
              _buildSubNode('📚', 'Academic APIs'),
              const SizedBox(width: 16),
              _buildSubNode('🎬', 'YouTube API'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubNode(String icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dashed wire simulation (solid for simplicity)
        Container(width: 2, height: 24, color: AppColors.primary.withValues(alpha: 0.4)),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 4)),
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12),
            ],
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDecisionNode() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.accentGreen.withValues(alpha: 0.2), blurRadius: 25),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.4)),
              boxShadow: [BoxShadow(color: AppColors.accentGreen.withValues(alpha: 0.3), blurRadius: 12)],
            ),
            child: const Center(child: Text('🔀', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Task Router', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              Text('Check Step Type', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBranches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildArmLabel('true'),
            const _Wire(),
            _buildBranchNode('💬', 'Socratic Tutor', 'Guided Dialogue & Clips', AppColors.primary),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            _buildArmLabel('false'),
            const _Wire(),
            _buildBranchNode('🏆', 'Quiz & XP Engine', 'Assessment & Rewards', AppColors.accentPink),
          ],
        ),
      ],
    );
  }

  Widget _buildArmLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0813),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBranchNode(String icon, String title, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.only(left: 6, right: 18, top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
              Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Wire extends StatelessWidget {
  const _Wire({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPort(),
        Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 8)],
          ),
        ),
        _buildPort(),
      ],
    );
  }

  Widget _buildPort() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFFA78BFA),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF0F172A), width: 2),
        boxShadow: const [BoxShadow(color: Color(0xFFA78BFA), blurRadius: 8)],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08);
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
