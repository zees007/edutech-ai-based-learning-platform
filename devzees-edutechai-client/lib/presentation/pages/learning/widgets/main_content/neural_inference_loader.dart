
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
    final isMobile = MediaQuery.of(context).size.width < 650;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 850),
          width: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 16,
            vertical: isMobile ? 12 : 24,
          ),
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1A30).withValues(alpha: 0.85), // Purple/blue glass background
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFA855F7).withValues(alpha: 0.65), // Illuminated neon border
              width: 1.5,
            ),
            boxShadow: [
              // Deep background drop shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
              // Vibrant neon border rim glow
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: 0.38),
                blurRadius: 18,
                spreadRadius: 2,
              ),
              // Broad ambient violet glow
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                blurRadius: 45,
                spreadRadius: 6,
              ),
              // Deep neon atmospheric halo
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                blurRadius: 80,
                spreadRadius: 12,
              ),
            ],
          ),
          child: isMobile ? _buildMobileContent() : _buildDesktopContent(),
        ),
      ),
    );
  }

  /// Mobile Compact View: Fits comfortably in a single screen (<400px height) without scrolling
  Widget _buildMobileContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Cluster Bar + Live Inference Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GradientSpinner(size: 11),
                const SizedBox(width: 6),
                Text(
                  'AI COMPUTE CLUSTER',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            _buildLiveInferenceBadge(isMobile: true),
          ],
        ),
        const SizedBox(height: 12),

        // Compact Gradient Title
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFEC4899), Color(0xFFA855F7)],
          ).createShader(bounds),
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 4),

        // Subtitle
        Text(
          widget.subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 14),

        // Centered Glowing Neural Core
        Center(
          child: SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing ambient halo
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 48 + 6 * _pulseController.value,
                      height: 48 + 6 * _pulseController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA855F7).withValues(
                              alpha: 0.25 + 0.15 * _pulseController.value,
                            ),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Rotating Gradient Spinner Ring
                const GradientSpinner(size: 46),
                // Inner AI Core Icon
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF151426),
                  ),
                  child: const Icon(
                    Icons.hub_outlined,
                    size: 15,
                    color: Color(0xFFEC4899),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Progress Bar
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: constraints.maxWidth * widget.progressPercent,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFA855F7), Color(0xFF06B6D4)],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),

        // 5 Agent Status Mini Chips (2-column compact layout)
        LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            final double chipWidth = (availableWidth - 8) / 2;

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildMobileAgentChip(
                  icon: '🧠',
                  name: 'Orchestrator',
                  status: 'completed',
                  width: chipWidth,
                ),
                _buildMobileAgentChip(
                  icon: '💬',
                  name: 'Socratic Tutor',
                  status: 'active',
                  width: chipWidth,
                ),
                _buildMobileAgentChip(
                  icon: '📺',
                  name: 'YouTube Curator',
                  status: 'active',
                  width: chipWidth,
                ),
                _buildMobileAgentChip(
                  icon: '📚',
                  name: 'Researcher',
                  status: 'active',
                  width: chipWidth,
                ),
                _buildMobileAgentChip(
                  icon: '📝',
                  name: 'Quiz Agent',
                  status: 'active',
                  width: chipWidth,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMobileAgentChip({
    required String icon,
    required String name,
    required String status,
    required double width,
  }) {
    final bool isCompleted = status == 'completed';
    final bool isActive = status == 'active';

    Color borderColor = Colors.white.withValues(alpha: 0.08);
    Color bgColor = const Color(0xFF151426).withValues(alpha: 0.7);
    List<BoxShadow> shadows = [];

    if (isActive) {
      borderColor = const Color(0xFFA855F7).withValues(alpha: 0.45);
      bgColor = const Color(0xFFA855F7).withValues(alpha: 0.08);
      shadows = [
        BoxShadow(
          color: const Color(0xFFA855F7).withValues(alpha: 0.12),
          blurRadius: 8,
        ),
      ];
    } else if (isCompleted) {
      borderColor = const Color(0xFF10B981).withValues(alpha: 0.45);
      bgColor = const Color(0xFF10B981).withValues(alpha: 0.08);
      shadows = [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: 0.12),
          blurRadius: 8,
        ),
      ];
    }

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
        boxShadow: shadows,
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: Text(
                '✓ Done',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF34D399),
                ),
              ),
            )
          else if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFA855F7).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.45)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const GradientSpinner(size: 8),
                  const SizedBox(width: 4),
                  Text(
                    'Active',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE879F9),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Desktop / Tablet View: Full expansive Compute Cluster Dashboard
  Widget _buildDesktopContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
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
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFA855F7)],
                  ).createShader(bounds),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: _buildLiveInferenceBadge(isMobile: false),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        const Divider(color: Colors.white12, height: 1),
        const SizedBox(height: 24),

        // Neural Network Canvas
        LayoutBuilder(
          builder: (context, constraints) {
            final double canvasWidth = constraints.maxWidth;
            const double canvasHeight = 150.0;

            return Container(
              width: double.infinity,
              height: canvasHeight + 40,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF151426),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) => CustomPaint(
                    size: Size(canvasWidth, canvasHeight),
                    painter: NeuralNetworkPainter(
                      animationValue: _pulseController.value,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Progress Bar
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: constraints.maxWidth * widget.progressPercent,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFA855F7), Color(0xFF06B6D4)],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // 5 Agent Workflow Cards (2 Columns)
        LayoutBuilder(
          builder: (context, constraints) {
            final double availableWidth = constraints.maxWidth;
            final double cardWidth = (availableWidth - 12) / 2;
            
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildAgentCard(
                  name: '🧠 Orchestrator Agent',
                  desc: 'Decomposing topic into structured, age-appropriate milestone roadmap.',
                  status: 'completed',
                  width: cardWidth,
                  isMobile: false,
                ),
                _buildAgentCard(
                  name: '💬 Socratic Tutor',
                  desc: 'Crafting deep intuitive explanations & interactive guiding questions.',
                  status: 'active',
                  width: cardWidth,
                  isMobile: false,
                ),
                _buildAgentCard(
                  name: '📺 YouTube Curator',
                  desc: 'Filtering high-yield educational videos with precise timestamp deep-linking.',
                  status: 'active',
                  width: cardWidth,
                  isMobile: false,
                ),
                _buildAgentCard(
                  name: '📚 Academic Researcher',
                  desc: 'Indexing peer-reviewed open access papers from OpenAlex & Semantic Scholar.',
                  status: 'active',
                  width: cardWidth,
                  isMobile: false,
                ),
                _buildAgentCard(
                  name: '📝 Quiz Agent',
                  desc: 'Structuring adaptive comprehension questions & XP reward multipliers.',
                  status: 'active',
                  width: cardWidth,
                  isMobile: false,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLiveInferenceBadge({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 10,
        vertical: isMobile ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.18),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseDotController,
            builder: (context, child) {
              return Container(
                width: isMobile ? 6 : 8,
                height: isMobile ? 6 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981),
                      blurRadius: (isMobile ? 6 : 8) * _pulseDotController.value,
                      spreadRadius: (isMobile ? 1.5 : 2) * _pulseDotController.value,
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(width: isMobile ? 4 : 6),
          Text(
            'LIVE INFERENCE',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard({
    required String name,
    required String desc,
    required String status,
    required double width,
    required bool isMobile,
  }) {
    final bool isActive = status == 'active';
    final bool isCompleted = status == 'completed';

    Color bgColor = Colors.white.withValues(alpha: 0.03);
    Color borderColor = Colors.white.withValues(alpha: 0.08);
    List<BoxShadow> shadows = [];

    if (isActive) {
      bgColor = const Color(0xFFA855F7).withValues(alpha: 0.05);
      borderColor = const Color(0xFFA855F7).withValues(alpha: 0.4);
      shadows = [
        BoxShadow(
          color: const Color(0xFFA855F7).withValues(alpha: 0.15),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    } else if (isCompleted) {
      bgColor = const Color(0xFF10B981).withValues(alpha: 0.05);
      borderColor = const Color(0xFF10B981).withValues(alpha: 0.4);
      shadows = [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: 0.12),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    }

    return Container(
      width: width,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: shadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusTag(status, isMobile: isMobile),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 11 : 12,
              color: const Color(0xFF9CA3AF),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status, {required bool isMobile}) {
    if (status == 'completed') {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 6 : 8,
          vertical: isMobile ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
        ),
        child: Text(
          '✓ COMPLETED',
          style: GoogleFonts.inter(
            fontSize: isMobile ? 9 : 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF34D399),
          ),
        ),
      );
    } else if (status == 'active') {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 6 : 8,
          vertical: isMobile ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFA855F7).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA855F7).withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientSpinner(size: isMobile ? 9 : 10),
            SizedBox(width: isMobile ? 4 : 6),
            Text(
              'EXECUTING...',
              style: GoogleFonts.inter(
                fontSize: isMobile ? 9 : 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE879F9),
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
              color: Color(0xFF1C1A30), // Match new container background
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
    // Scale X and Y to fit available size
    final scaleX = size.width / 800;
    final scaleY = size.height / 150;
    
    Offset getPt(double x, double y) {
      return Offset(x * scaleX, y * scaleY);
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
