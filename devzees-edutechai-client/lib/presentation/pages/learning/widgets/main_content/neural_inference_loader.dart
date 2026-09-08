
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeuralInferenceLoader extends StatefulWidget {
  final String title;
  final String subtitle;
  final double progressPercent;

  const NeuralInferenceLoader({
    super.key,
    required this.title,
    required this.subtitle,
    this.progressPercent = 0.7, // Equivalent to 70% in Streamlit
  });

  @override
  State<NeuralInferenceLoader> createState() => _NeuralInferenceLoaderState();
}

class _NeuralInferenceLoaderState extends State<NeuralInferenceLoader>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _pulseDotController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseDotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pulseDotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 800,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF14141E).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
            // Glowing border effect
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
              blurRadius: 60,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const GradientSpinner(size: 14),
                          const SizedBox(width: 8),
                          Text(
                            'EDU-TECH AI COMPUTE CLUSTER  •  NEURAL INFERENCE',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                // Live inference badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseDotController,
                        builder: (context, child) {
                          return Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF10B981),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981),
                                  blurRadius: 8 * _pulseDotController.value,
                                  spreadRadius: 2 * _pulseDotController.value,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LIVE INFERENCE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Neural Network Canvas (SVG replica)
            SizedBox(
              height: 150,
              width: double.infinity,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: NeuralNetworkPainter(
                        animationValue: _pulseController.value,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress Bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: (MediaQuery.of(context).size.width.clamp(0.0, 800.0) - 64) * widget.progressPercent,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFA855F7), Color(0xFF06B6D4)],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Agent Workflow Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildAgentCard(
                  name: '🧠 Orchestrator Agent',
                  desc: 'Decomposing topic into structured, age-appropriate milestone roadmap.',
                  status: 'completed',
                ),
                _buildAgentCard(
                  name: '💬 Socratic Tutor',
                  desc: 'Crafting deep intuitive explanations & interactive guiding questions.',
                  status: 'active',
                ),
                _buildAgentCard(
                  name: '📺 YouTube Curator',
                  desc: 'Filtering high-yield educational videos with precise timestamp deep-linking.',
                  status: 'active',
                ),
                _buildAgentCard(
                  name: '📚 Academic Researcher',
                  desc: 'Indexing peer-reviewed open access papers from OpenAlex & Semantic Scholar.',
                  status: 'active',
                ),
                _buildAgentCard(
                  name: '📝 Quiz Agent',
                  desc: 'Structuring adaptive comprehension questions & XP reward multipliers.',
                  status: 'active',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentCard({
    required String name,
    required String desc,
    required String status,
  }) {
    final bool isActive = status == 'active';
    final bool isCompleted = status == 'completed';

    Color bgColor = Colors.white.withValues(alpha: 0.03);
    Color borderColor = Colors.white.withValues(alpha: 0.08);

    if (isActive) {
      bgColor = const Color(0xFF3B82F6).withValues(alpha: 0.05);
      borderColor = const Color(0xFF3B82F6).withValues(alpha: 0.3);
    } else if (isCompleted) {
      bgColor = const Color(0xFF10B981).withValues(alpha: 0.05);
      borderColor = const Color(0xFF10B981).withValues(alpha: 0.3);
    }

    return Container(
      width: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              _buildStatusTag(status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    if (status == 'completed') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '✓ COMPLETED',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF34D399),
          ),
        ),
      );
    } else if (status == 'active') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GradientSpinner(size: 10),
            const SizedBox(width: 6),
            Text(
              'EXECUTING...',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF60A5FA),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }
}

class GradientSpinner extends StatefulWidget {
  final double size;
  const GradientSpinner({super.key, required this.size});

  @override
  State<GradientSpinner> createState() => _GradientSpinnerState();
}

class _GradientSpinnerState extends State<GradientSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(
            colors: [Color(0xFF3B82F6), Color(0xFFEC4899), Colors.transparent],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF14141E), // Match background to make it a ring
            ),
          ),
        ),
      ),
    );
  }
}

class NeuralNetworkPainter extends CustomPainter {
  final double animationValue;

  NeuralNetworkPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Map of node coordinates (matching SVG viewBox 0 0 800 150)
    // Scale X to fit available width
    final scaleX = size.width / 800;
    
    Offset getPt(double x, double y) {
      return Offset(x * scaleX, y);
    }

    // Nodes
    final topic = getPt(80, 35);
    final contextNode = getPt(80, 115);
    
    final orchestrator = getPt(280, 25);
    final roadmap = getPt(280, 75);
    final vectorRag = getPt(280, 125);
    
    final socratic = getPt(520, 25);
    final youtube = getPt(520, 75);
    final academic = getPt(520, 125);
    
    final workspace = getPt(720, 75);

    // Draw lines
    final paintLine = Paint()..style = PaintingStyle.stroke..strokeWidth = 2;

    void drawLine(Offset p1, Offset p2, Color color) {
      paintLine.color = color;
      canvas.drawLine(p1, p2, paintLine);
    }

    final pinkLine = const Color(0xFFEC4899).withValues(alpha: 0.35);
    final purpleLine = const Color(0xFFA855F7).withValues(alpha: 0.4);
    final blueLine = const Color(0xFF3B82F6).withValues(alpha: 0.4);
    final cyanLine = const Color(0xFF06B6D4).withValues(alpha: 0.4);
    final greenLine = const Color(0xFF10B981).withValues(alpha: 0.4);

    drawLine(topic, orchestrator, pinkLine);
    drawLine(topic, roadmap, pinkLine);
    drawLine(topic, vectorRag, pinkLine);
    drawLine(contextNode, orchestrator, pinkLine);
    drawLine(contextNode, roadmap, pinkLine);
    drawLine(contextNode, vectorRag, pinkLine);

    drawLine(orchestrator, socratic, purpleLine);
    drawLine(orchestrator, youtube, purpleLine);
    drawLine(roadmap, youtube, purpleLine);
    drawLine(roadmap, academic, purpleLine);
    drawLine(vectorRag, youtube, purpleLine);
    drawLine(vectorRag, academic, purpleLine);

    drawLine(socratic, workspace, blueLine);
    drawLine(youtube, workspace, cyanLine);
    drawLine(academic, workspace, greenLine);

    // Draw traveling pulses (interpolate between x1 and x2)
    final pulsePaint = Paint()..style = PaintingStyle.fill;
    
    Offset lerp(Offset p1, Offset p2, double t) {
      return Offset(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
    }

    // Pulse 1: Topic -> Orchestrator
    pulsePaint.color = const Color(0xFFEC4899);
    canvas.drawCircle(lerp(topic, orchestrator, animationValue), 4, pulsePaint);
    
    // Pulse 2: Orchestrator -> YouTube
    pulsePaint.color = const Color(0xFFA855F7);
    canvas.drawCircle(lerp(orchestrator, youtube, (animationValue + 0.3) % 1.0), 4, pulsePaint);

    // Pulse 3: YouTube -> Workspace
    pulsePaint.color = const Color(0xFF3B82F6);
    canvas.drawCircle(lerp(youtube, workspace, (animationValue + 0.6) % 1.0), 4, pulsePaint);

    // Draw Nodes
    void drawNode(Offset pt, double r, Color strokeColor, String emoji, String label, double strokeW) {
      final fillPaint = Paint()..style = PaintingStyle.fill..color = const Color(0xFF0F172A);
      final borderPaint = Paint()..style = PaintingStyle.stroke..color = strokeColor..strokeWidth = strokeW;
      
      canvas.drawCircle(pt, r, fillPaint);
      canvas.drawCircle(pt, r, borderPaint);

      // We'll use TextPainter for emoji and text
      final emojiPainter = TextPainter(
        text: TextSpan(text: emoji, style: const TextStyle(fontSize: 12)),
        textDirection: TextDirection.ltr,
      )..layout();
      
      emojiPainter.paint(
        canvas, 
        Offset(pt.dx - emojiPainter.width / 2, pt.dy - emojiPainter.height / 2)
      );

      final labelPainter = TextPainter(
        text: TextSpan(
          text: label, 
          style: GoogleFonts.inter(
            fontSize: 10, 
            fontWeight: FontWeight.w700,
            color: strokeColor,
          )
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      
      labelPainter.paint(
        canvas, 
        Offset(pt.dx - labelPainter.width / 2, pt.dy + r + 4)
      );
    }

    drawNode(topic, 16, const Color(0xFFEC4899), '🎯', 'Topic', 3);
    drawNode(contextNode, 16, const Color(0xFFF43F5E), '👤', 'Context', 3);
    
    drawNode(orchestrator, 17, const Color(0xFFA855F7), '🧠', 'Orchestrator', 3);
    drawNode(roadmap, 15, const Color(0xFF8B5CF6), '⚡', 'Roadmap', 3);
    drawNode(vectorRag, 15, const Color(0xFF7C3AED), '📊', 'Vector RAG', 3);

    drawNode(socratic, 16, const Color(0xFF3B82F6), '💬', 'Socratic', 3);
    drawNode(youtube, 16, const Color(0xFF06B6D4), '📺', 'YouTube', 3);
    drawNode(academic, 16, const Color(0xFF10B981), '📚', 'Academic', 3);

    drawNode(workspace, 22, const Color(0xFFEC4899), '🎓', 'Workspace', 4);
  }

  @override
  bool shouldRepaint(covariant NeuralNetworkPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
