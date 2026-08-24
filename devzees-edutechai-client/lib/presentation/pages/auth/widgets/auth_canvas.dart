import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';

class AuthCanvas extends StatefulWidget {
  final bool isLogin;
  final ValueChanged<bool> onAuthModeChanged;

  const AuthCanvas({
    Key? key,
    required this.isLogin,
    required this.onAuthModeChanged,
  }) : super(key: key);

  @override
  State<AuthCanvas> createState() => _AuthCanvasState();
}

class _AuthCanvasState extends State<AuthCanvas> with SingleTickerProviderStateMixin {
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

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0B0813),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.15 + (0.1 * t)),
                blurRadius: 40 + (10 * t),
                spreadRadius: -10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Background Gradients & Dots
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const FractionalOffset(0.2, 0.3),
                        radius: 0.8,
                        colors: [
                          const Color(0xFFA855F7).withValues(alpha: 0.12),
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
                          const Color(0xFF3B82F6).withValues(alpha: 0.12),
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
                
                // Content Flowchart
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA855F7).withValues(alpha: 0.1),
                          border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          '⚡ EduTech AI — Providing Access Flowchart',
                          style: TextStyle(
                            color: Color(0xFFE9D5FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Step 1
                      _buildFlowNode(
                        icon: '👤',
                        tag: 'STEP 01 • INTAKE',
                        title: 'User Arrival',
                        subtitle: 'Initiates secure session request',
                        baseColor: const Color(0xFF3B82F6), // Blue
                        isGradientText: true,
                      ),
                      _buildArrow(),
                      
                      // Step 2
                      _buildFlowNode(
                        icon: '🛡️',
                        tag: 'STEP 02 • AI EVALUATION',
                        title: 'AI Identity Guard',
                        subtitle: 'Inspects credentials & privileges',
                        baseColor: const Color(0xFFA855F7), // Purple
                        isGradientText: true,
                      ),
                      _buildArrow(),
                      
                      // Step 3
                      _buildFlowNode(
                        icon: '❓',
                        tag: 'STEP 03 • ROUTING GATEWAY',
                        title: 'Account Verification',
                        subtitle: 'Determines authentication pathway',
                        baseColor: const Color(0xFFEC4899), // Pink
                        isGradientText: true,
                      ),
                      
                      const SizedBox(height: 16),
                      // Branches
                      Row(
                        children: [
                          Expanded(
                            child: _buildBranch(
                              label: 'YES • EXISTING USER (✓)',
                              color: const Color(0xFF34D399), // Green
                            ),
                          ),
                          Expanded(
                            child: _buildBranch(
                              label: 'NO • NEW STUDENT (✨)',
                              color: const Color(0xFFF472B6), // Pink
                            ),
                          ),
                        ],
                      ),
                      
                      // Step 4 Actions (The Buttons)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildActionNode(
                              icon: '🔐',
                              tag: 'STEP 04A • LOGIN',
                              title: 'Sign In',
                              subtitle: 'Existing Account Access',
                              isActive: widget.isLogin,
                              baseColor: const Color(0xFF34D399),
                              isGradientText: true,
                              onTap: () => widget.onAuthModeChanged(true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionNode(
                              icon: '✨',
                              tag: 'STEP 04B • REGISTER',
                              title: 'Create Account',
                              subtitle: 'Instant Free Setup',
                              isActive: !widget.isLogin,
                              baseColor: const Color(0xFFF472B6),
                              isGradientText: true,
                              onTap: () => widget.onAuthModeChanged(false),
                            ),
                          ),
                        ],
                      ),
                      
                      // Merge arrows
                      _buildMergeArrows(),
                      
                      // Step 5
                      _buildFlowNode(
                        icon: '🧠',
                        tag: 'STEP 05 • DISPATCH & UNLOCK',
                        title: 'Spawn AI Agent Squad',
                        subtitle: 'Instant Autonomous Workspace Access',
                        baseColor: const Color(0xFF06B6D4), // Cyan
                        isGradientText: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlowNode({
    required String icon,
    required String tag,
    required String title,
    required String subtitle,
    required Color baseColor,
    bool isGradientText = false,
  }) {
    return Container(
      width: 250, // Reduced from 280
      padding: const EdgeInsets.all(12), // Reduced from 16
      decoration: BoxDecoration(
        color: const Color(0xFF151025).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.25),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10), // Reduced from 12
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: baseColor.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(color: baseColor.withValues(alpha: 0.6), blurRadius: 15),
              ],
            ),
            child: Text(icon, style: const TextStyle(fontSize: 18)), // Reduced from 20
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: baseColor.withValues(alpha: 0.9),
                      fontSize: 8, // Reduced from 9
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (isGradientText)
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFFA855F7), Color(0xFF3B82F6)],
                    ).createShader(bounds),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13, // Reduced from 14
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13, // Reduced from 14
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10, // Reduced from 11
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            width: 2,
            height: 20,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          Icon(Icons.keyboard_arrow_down, color: Colors.white.withValues(alpha: 0.3), size: 16),
        ],
      ),
    );
  }

  Widget _buildBranch({required String label, required Color color}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          width: 2,
          height: 16,
          color: color.withValues(alpha: 0.4),
        ),
        Icon(Icons.keyboard_arrow_down, color: color, size: 16),
      ],
    );
  }

  Widget _buildActionNode({
    required String icon,
    required String tag,
    required String title,
    required String subtitle,
    required bool isActive,
    required Color baseColor,
    required VoidCallback onTap,
    bool isGradientText = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12), // Reduced from 16
          decoration: BoxDecoration(
            color: isActive ? baseColor.withValues(alpha: 0.15) : const Color(0xFF151025).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? baseColor.withValues(alpha: 0.6) : baseColor.withValues(alpha: 0.3),
              width: isActive ? 1.5 : 1.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: baseColor.withValues(alpha: 0.35),
                      blurRadius: 35,
                      spreadRadius: -2,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: baseColor.withValues(alpha: 0.1),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced from 12
                decoration: BoxDecoration(
                  color: baseColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: baseColor.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(color: baseColor.withValues(alpha: 0.6), blurRadius: 15),
                  ],
                ),
                child: Text(icon, style: const TextStyle(fontSize: 18)), // Reduced from 20
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: baseColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: isActive ? baseColor : baseColor.withValues(alpha: 0.9),
                          fontSize: 8, // Reduced from 9
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isGradientText)
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFFA855F7), Color(0xFF3B82F6)],
                        ).createShader(bounds),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.white70,
                            fontSize: 13, // Reduced from 14
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    else
                      Text(
                        title,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white70,
                          fontSize: 13, // Reduced from 14
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isActive ? Colors.white70 : Colors.white.withValues(alpha: 0.5),
                        fontSize: 10, // Reduced from 11
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMergeArrows() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 30,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CustomPaint(
              size: const Size(double.infinity, 30),
              painter: _MergeArrowPainter(),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF06B6D4), size: 16),
          ],
        ),
      ),
    );
  }
}

class _MergeArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF34D399).withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paint2 = Paint()
      ..color = const Color(0xFFF472B6).withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintMerge = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Left branch down
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.25, size.height * 0.5),
      paint1,
    );
    // Right branch down
    canvas.drawLine(
      Offset(size.width * 0.75, 0),
      Offset(size.width * 0.75, size.height * 0.5),
      paint2,
    );
    // Horizontal merge
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.5),
      paintMerge, // Using cyan for the merge line
    );
    // Center down
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.5, size.height - 5),
      paintMerge,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    
    const spacing = 15.0;
    const radius = 1.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
