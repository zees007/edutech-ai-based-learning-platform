import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/constants/responsive.dart';

/// Ultra-Premium 3D Holographic AI Blackboard Core Centerpiece.
///
/// Engineered with Framer-grade motion aesthetics:
/// - Liquid spring mouse-tilt 3D perspective projection.
/// - Atmospheric quantum nebula with drifting particle starfield.
/// - Multi-layered gyroscopic HUD reticles, compass ticks, and rotating telemetry rings.
/// - High-tech vector iconography with custom illuminated backplates (no raw emojis).
/// - Pulsing quantum singularity core with dancing waveform audio bars and breathing aperture.
/// - Dynamic laser data streams with trailing comet photon packets and depth-sorted nodes.
/// - Mission Control live telemetry dock with real-time waveform and mesh stats.
class Hero3DAICore extends StatefulWidget {
  const Hero3DAICore({super.key});

  @override
  State<Hero3DAICore> createState() => _Hero3DAICoreState();
}

class _Hero3DAICoreState extends State<Hero3DAICore>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbitController;

  double _mouseX = 0.0;
  double _mouseY = 0.0;
  double _targetMouseX = 0.0;
  double _targetMouseY = 0.0;

  int? _hoveredAgentIndex;
  int? _selectedAgentIndex;

  // Stardust particle field
  static final List<_QuantumParticle> _particles = List.generate(
    36,
    (index) => _QuantumParticle(
      x: (index * 47 % 100) / 100 * 2 - 1,
      y: (index * 73 % 100) / 100 * 2 - 1,
      size: (index % 3 == 0) ? 2.4 : ((index % 2 == 0) ? 1.8 : 1.2),
      speed: 0.3 + (index % 5) * 0.15,
      phase: index * 0.45,
    ),
  );

  static const List<_AgentOrbitalData> _agents = [
    _AgentOrbitalData(
      id: 'AGENT_01',
      icon: Icons.account_tree_rounded,
      name: 'Orchestrator',
      color: Color(0xFF6366F1), // Electric Indigo
      accentColor: Color(0xFFA5B4FC),
      role: 'SUPERVISOR KERNEL',
      status: 'Decomposing milestone prerequisites & DAG graph state',
      metric: 'DAG SYNC 99.8%',
      latency: '12ms',
    ),
    _AgentOrbitalData(
      id: 'AGENT_02',
      icon: Icons.psychology_rounded,
      name: 'Socratic Tutor',
      color: Color(0xFF00F5D4), // Cyber Mint / Cyan
      accentColor: Color(0xFF5EEAD4),
      role: 'COGNITIVE GUIDE',
      status: 'Active guided inquiry, Socratic prompts & everyday analogies',
      metric: 'GROUNDED 100%',
      latency: '24ms',
    ),
    _AgentOrbitalData(
      id: 'AGENT_03',
      icon: Icons.smart_display_rounded,
      name: 'Video Curator',
      color: Color(0xFFEC4899), // Neon Pink
      accentColor: Color(0xFFF472B6),
      role: 'CLIP LOCATOR',
      status: 'Pinpointing verified YouTube timestamped vector clips',
      metric: 'PRECISION 98.4%',
      latency: '36ms',
    ),
    _AgentOrbitalData(
      id: 'AGENT_04',
      icon: Icons.auto_stories_rounded,
      name: 'Researcher',
      color: Color(0xFF38BDF8), // Sky Blue
      accentColor: Color(0xFF7DD3FC),
      role: 'ACADEMIC SYNTHESIS',
      status: 'Querying 250M+ arXiv & OpenAlex peer-reviewed preprints',
      metric: 'PAPERS 250M+',
      latency: '48ms',
    ),
    _AgentOrbitalData(
      id: 'AGENT_05',
      icon: Icons.verified_rounded,
      name: 'Quiz Evaluator',
      color: Color(0xFFF59E0B), // Golden Amber
      accentColor: Color(0xFFFCD34D),
      role: 'FORMATIVE GRADER',
      status: 'Generating formative checks, instant grading & XP ledger',
      metric: 'MASTERY CHECK',
      latency: '18ms',
    ),
    _AgentOrbitalData(
      id: 'AGENT_06',
      icon: Icons.bolt_rounded,
      name: 'Synthesizer',
      color: Color(0xFFA855F7), // Vivid Ultraviolet
      accentColor: Color(0xFFC084FC),
      role: 'STATE SYNTHESIS',
      status: 'Streaming live WebSocket state & Second Brain markdown exports',
      metric: '60 FPS STREAM',
      latency: '8ms',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final Size size = box.size;
    if (size.width <= 0 || size.height <= 0) return;

    _targetMouseX = (event.localPosition.dx / size.width) * 2 - 1;
    _targetMouseY = (event.localPosition.dy / size.height) * 2 - 1;
  }

  void _onExit(PointerEvent event) {
    _targetMouseX = 0.0;
    _targetMouseY = 0.0;
    _hoveredAgentIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final double height = isMobile ? 360 : 490;

    return MouseRegion(
      onHover: _onHover,
      onExit: _onExit,
      child: AnimatedBuilder(
        animation: _orbitController,
        builder: (context, _) {
          // Ultra-smooth spring damping lerp (Framer feel)
          _mouseX += (_targetMouseX - _mouseX) * 0.07;
          _mouseY += (_targetMouseY - _mouseY) * 0.07;

          final double time = _orbitController.value * 2 * math.pi;

          return SizedBox(
            width: double.infinity,
            height: height,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 1. High-Tech Gyroscopic Canvas with HUD Rings & Photon Beams
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CoreHolographicPainter(
                      time: time,
                      tiltX: _mouseY * 0.32,
                      tiltY: _mouseX * 0.40,
                      isMobile: isMobile,
                      agents: _agents,
                      particles: _particles,
                      hoveredIndex: _hoveredAgentIndex ?? _selectedAgentIndex,
                    ),
                  ),
                ),

                // 2. Central Quantum Blackboard Reactor Core
                _buildCentralCore(isMobile, time),

                // 3. Depth-Sorted Vector Agent Satellites
                ..._buildAgentSatellites(time, isMobile),

                // 4. Mission Control Live Telemetry Dock
                Positioned(
                  bottom: isMobile ? 6 : 14,
                  child: _buildTelemetryDock(isMobile, time),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Central Quantum Reactor Singularity
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildCentralCore(bool isMobile, double time) {
    final double coreSize = isMobile ? 104 : 144;
    final double breathingScale = 1.0 + 0.035 * math.sin(time * 2.2);

    return Transform.scale(
      scale: breathingScale,
      child: Container(
        width: coreSize,
        height: coreSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFF7DD3FC),
              Color(0xFF6366F1),
              Color(0xFF1E1B4B),
              Color(0xFF040612),
            ],
            stops: [0.0, 0.22, 0.52, 0.82, 1.0],
          ),
          boxShadow: [
            // Deep ambient core glow
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.60),
              blurRadius: isMobile ? 35 : 55,
              spreadRadius: 4,
            ),
            // Cyan spectral aura
            BoxShadow(
              color: const Color(0xFF00F5D4).withValues(alpha: 0.40),
              blurRadius: isMobile ? 55 : 85,
              spreadRadius: 8,
            ),
            // Outer magenta atmospheric bloom
            BoxShadow(
              color: const Color(0xFFA855F7).withValues(alpha: 0.25),
              blurRadius: isMobile ? 80 : 120,
              spreadRadius: 12,
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.85),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dynamic rotating reticle icon
                    Transform.rotate(
                      angle: time * 0.4,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          Icons.hub_rounded,
                          color: Colors.white,
                          size: isMobile ? 22 : 28,
                          shadows: const [
                            Shadow(
                              color: Color(0xFF00F5D4),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // High-tech typography
                    Text(
                      'AI BLACKBOARD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 8.5 : 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.8),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00F5D4),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF00F5D4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'SYNCHRONIZED',
                          style: TextStyle(
                            color: const Color(0xFF00F5D4),
                            fontSize: isMobile ? 6.5 : 7.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Active Waveform Audio/Telemetry Bars
                    _buildMicroWaveform(isMobile, time),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Micro Waveform Animation (Simulating Real-Time Thinking)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildMicroWaveform(bool isMobile, double time) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final double barHeight = 4.0 + 7.0 * math.sin(time * 4.0 + i * 1.2).abs();
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.2),
          width: 2.0,
          height: barHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF7DD3FC).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 3D Depth-Sorted Vector Agent Satellites
  // ═══════════════════════════════════════════════════════════════════
  List<Widget> _buildAgentSatellites(double time, bool isMobile) {
    final double radiusX = (isMobile ? 150 : 250);
    final double radiusY = (isMobile ? 65 : 100);
    final List<Widget> satellites = [];

    for (int i = 0; i < _agents.length; i++) {
      final agent = _agents[i];
      final double angle = time + (i * 2 * math.pi / _agents.length);

      final double rawX = math.cos(angle) * radiusX;
      final double rawY = math.sin(angle) * radiusY;

      // 3D Isometric inclination
      final double cosTilt = math.cos(_mouseY * 0.35);
      final double rotatedY = rawY * cosTilt + math.sin(_mouseX * 0.35) * 26;

      // Depth z axis: -1 (rear) to +1 (front)
      final double z = math.sin(angle);
      final double depthScale = 0.85 + (z + 1) * 0.22; // 0.85 to 1.29
      final double depthOpacity = 0.52 + (z + 1) * 0.24; // 0.52 to 1.0

      final bool isHovered = (_hoveredAgentIndex == i) || (_selectedAgentIndex == i);
      final bool isFront = z > -0.25;

      satellites.add(
        Transform.translate(
          offset: Offset(rawX, rotatedY),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredAgentIndex = i),
            onExit: (_) => setState(() => _hoveredAgentIndex = null),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAgentIndex = (_selectedAgentIndex == i) ? null : i;
                });
              },
              child: Opacity(
                opacity: isHovered ? 1.0 : depthOpacity.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: isHovered ? 1.38 : depthScale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // High-Tech Vector Satellite Node
                      _buildSatelliteNode(agent, isHovered, isMobile),

                      // Holographic Agent Identification Tag (Front or Hovered)
                      if (isFront || isHovered) ...[
                        const SizedBox(height: 6),
                        _buildAgentTag(agent, isHovered, isMobile),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return satellites;
  }

  // ═══════════════════════════════════════════════════════════════════
  // High-Tech Vector Satellite Node (Glassmorphic Hex/Sphere)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSatelliteNode(_AgentOrbitalData agent, bool isHovered, bool isMobile) {
    final double nodeSize = isMobile ? 38 : 46;

    return Container(
      width: nodeSize,
      height: nodeSize,
      decoration: BoxDecoration(
        color: const Color(0xF80A0C16),
        shape: BoxShape.circle,
        border: Border.all(
          color: isHovered
              ? Colors.white
              : agent.color.withValues(alpha: 0.85),
          width: isHovered ? 2.0 : 1.3,
        ),
        boxShadow: [
          // Ambient neon backlight glow
          BoxShadow(
            color: agent.color.withValues(alpha: isHovered ? 0.85 : 0.40),
            blurRadius: isHovered ? 28 : 16,
            spreadRadius: isHovered ? 4 : 1,
          ),
          if (isHovered)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.45),
              blurRadius: 14,
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle concentric inner ring
          Container(
            width: nodeSize - 12,
            height: nodeSize - 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: agent.color.withValues(alpha: 0.12),
              border: Border.all(
                color: agent.color.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
          ),
          // Precision Vector Icon
          Icon(
            agent.icon,
            color: isHovered ? Colors.white : agent.accentColor,
            size: isMobile ? 18 : 22,
            shadows: [
              Shadow(
                color: agent.color.withValues(alpha: 0.85),
                blurRadius: 10,
              ),
            ],
          ),
          // Mini Telemetry Status LED
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isHovered ? const Color(0xFF00F5D4) : agent.color,
                boxShadow: [
                  BoxShadow(
                    color: isHovered ? const Color(0xFF00F5D4) : agent.color,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Holographic Agent Tag with Designation Badge
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAgentTag(_AgentOrbitalData agent, bool isHovered, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xEE080A14),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: agent.color.withValues(alpha: isHovered ? 0.95 : 0.45),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 8,
          ),
          if (isHovered)
            BoxShadow(
              color: agent.color.withValues(alpha: 0.3),
              blurRadius: 12,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: agent.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              agent.id,
              style: TextStyle(
                color: agent.accentColor,
                fontSize: isMobile ? 7 : 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            agent.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 9 : 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Mission Control Live Telemetry Dock (Bottom Frosted Pill)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTelemetryDock(bool isMobile, double time) {
    final activeIndex = _hoveredAgentIndex ?? _selectedAgentIndex;
    final activeAgent = activeIndex != null ? _agents[activeIndex] : null;

    final String title = activeAgent != null
        ? '${activeAgent.name} [${activeAgent.role}]'
        : '6-AGENT MULTI-MODEL BLACKBOARD KERNEL';

    final String status = activeAgent != null
        ? activeAgent.status
        : 'Synchronous state vector active • Streaming at 60 FPS • Autonomous consensus';

    final String badge = activeAgent != null
        ? activeAgent.metric
        : 'FULL MESH ONLINE';

    final Color primaryColor = activeAgent?.color ?? const Color(0xFF00F5D4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      constraints: BoxConstraints(maxWidth: isMobile ? 350 : 720),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 18,
        vertical: isMobile ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xF4070812),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.55),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live Pulse Radar Dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Core Info Text
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 10.5 : 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: isMobile ? 8 : 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  status,
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: isMobile ? 9 : 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Latency chip (desktop)
          if (!isMobile) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flash_on_rounded, size: 11, color: Color(0xFF00F5D4)),
                  const SizedBox(width: 3),
                  Text(
                    activeAgent?.latency ?? '60 FPS',
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Agent Data Model
// ═══════════════════════════════════════════════════════════════════
class _AgentOrbitalData {
  final String id;
  final IconData icon;
  final String name;
  final Color color;
  final Color accentColor;
  final String role;
  final String status;
  final String metric;
  final String latency;

  const _AgentOrbitalData({
    required this.id,
    required this.icon,
    required this.name,
    required this.color,
    required this.accentColor,
    required this.role,
    required this.status,
    required this.metric,
    required this.latency,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Quantum Stardust Particle Model
// ═══════════════════════════════════════════════════════════════════
class _QuantumParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;

  const _QuantumParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

// ═══════════════════════════════════════════════════════════════════
// CustomPainter: Framer-Grade Gyro Rings, Beams & HUD Reticles
// ═══════════════════════════════════════════════════════════════════
class _CoreHolographicPainter extends CustomPainter {
  final double time;
  final double tiltX;
  final double tiltY;
  final bool isMobile;
  final List<_AgentOrbitalData> agents;
  final List<_QuantumParticle> particles;
  final int? hoveredIndex;

  _CoreHolographicPainter({
    required this.time,
    required this.tiltX,
    required this.tiltY,
    required this.isMobile,
    required this.agents,
    required this.particles,
    required this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double radiusX = (isMobile ? 150 : 250);
    final double radiusY = (isMobile ? 65 : 100);

    // ─── 0. Ambient Deep Space Nebula Glow ───
    final Paint nebulaPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        isMobile ? 200 : 320,
        [
          const Color(0xFF6366F1).withValues(alpha: 0.16),
          const Color(0xFFA855F7).withValues(alpha: 0.08),
          const Color(0xFF00F5D4).withValues(alpha: 0.03),
          Colors.transparent,
        ],
        [0.0, 0.4, 0.75, 1.0],
      );
    canvas.drawCircle(center, isMobile ? 220 : 350, nebulaPaint);

    // ─── 1. Quantum Stardust Particle Constellation ───
    for (int p = 0; p < particles.length; p++) {
      final particle = particles[p];
      final double twinkle = (math.sin(time * particle.speed + particle.phase) + 1) / 2;
      final double px = center.dx + particle.x * (size.width * 0.44) + math.sin(tiltY) * 15;
      final double py = center.dy + particle.y * (size.height * 0.38) + math.cos(tiltX) * 12;

      final Paint particlePaint = Paint()
        ..color = (p % 2 == 0 ? const Color(0xFF7DD3FC) : const Color(0xFFC084FC))
            .withValues(alpha: 0.15 + twinkle * 0.50)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(px, py), particle.size * (0.8 + twinkle * 0.4), particlePaint);
    }

    // ─── 2. Receding Holographic Radar Pulse Wave ───
    final double pulseProgress = (time * 0.6) % 1.0;
    final double pulseRadius = (isMobile ? 60 : 90) + pulseProgress * (isMobile ? 180 : 280);
    final double pulseOpacity = (1.0 - pulseProgress).clamp(0.0, 1.0) * 0.45;

    final Paint pulsePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFF00F5D4).withValues(alpha: pulseOpacity);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1.0, 0.42);
    canvas.drawCircle(Offset.zero, pulseRadius, pulsePaint);
    canvas.restore();

    // ─── 3. Concentric Gyroscopic HUD Reticle Rings ───
    // Ring 1: Primary Gradient Orbital Ellipse
    final Paint ring1Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF6366F1).withValues(alpha: 0.05),
          const Color(0xFF00F5D4).withValues(alpha: 0.80),
          const Color(0xFFA855F7).withValues(alpha: 0.85),
          const Color(0xFF38BDF8).withValues(alpha: 0.70),
          const Color(0xFF6366F1).withValues(alpha: 0.05),
        ],
        transform: GradientRotation(time * 0.7),
      ).createShader(Rect.fromCircle(center: center, radius: 260));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tiltY * 0.45);
    canvas.scale(1.0, (isMobile ? 0.43 : 0.40) + tiltX * 0.18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: isMobile ? 300 : 500,
        height: isMobile ? 300 : 500,
      ),
      ring1Paint,
    );

    // Calibration Tick Marks on Ring 1
    final Paint tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 1.0;

    const int totalTicks = 32;
    for (int t = 0; t < totalTicks; t++) {
      final double tickAngle = t * 2 * math.pi / totalTicks;
      final double r1 = (isMobile ? 150 : 250);
      final double r2 = r1 + (t % 4 == 0 ? 5 : 2.5);

      final p1 = Offset(math.cos(tickAngle) * r1, math.sin(tickAngle) * r1);
      final p2 = Offset(math.cos(tickAngle) * r2, math.sin(tickAngle) * r2);
      canvas.drawLine(p1, p2, tickPaint);
    }
    canvas.restore();

    // Ring 2: Counter-Rotating Equatorial Ring with Dashed Arcs
    final Paint ring2Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = SweepGradient(
        colors: [
          const Color(0xFFEC4899).withValues(alpha: 0.05),
          const Color(0xFFEC4899).withValues(alpha: 0.65),
          const Color(0xFFF59E0B).withValues(alpha: 0.70),
          const Color(0xFFEC4899).withValues(alpha: 0.05),
        ],
        transform: GradientRotation(-time * 1.0),
      ).createShader(Rect.fromCircle(center: center, radius: 220));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-tiltY * 0.6 + math.pi / 5);
    canvas.scale(1.0, 0.44 - tiltX * 0.14);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: isMobile ? 210 : 340,
        height: isMobile ? 210 : 340,
      ),
      ring2Paint,
    );
    canvas.restore();

    // Ring 3: Fine Rotating Outer Horizon Dial
    final Paint ring3Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.12);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(time * 0.25);
    canvas.scale(1.0, 0.32);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: isMobile ? 360 : 580,
        height: isMobile ? 360 : 580,
      ),
      ring3Paint,
    );
    canvas.restore();

    // ─── 4. Laser Data Beams with Traveling Photon Comet Sparks ───
    for (int i = 0; i < agents.length; i++) {
      final agent = agents[i];
      final double angle = time + (i * 2 * math.pi / agents.length);

      final double rawX = math.cos(angle) * radiusX;
      final double rawY = math.sin(angle) * radiusY;
      final double cosTilt = math.cos(tiltX);
      final double rotatedY = rawY * cosTilt + math.sin(tiltY) * 26;

      final Offset nodePos = Offset(center.dx + rawX, center.dy + rotatedY);

      final double z = math.sin(angle);
      final double depthAlpha = ((z + 1) * 0.5).clamp(0.25, 0.95);
      final bool isHovered = (i == hoveredIndex);

      // Multi-pass glowing beam
      // Pass A: Wide soft glow
      final Paint glowBeam = Paint()
        ..color = agent.color.withValues(alpha: (isHovered ? 0.35 : 0.10) * depthAlpha)
        ..strokeWidth = isHovered ? 4.0 : 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center, nodePos, glowBeam);

      // Pass B: Crisp core laser
      final Paint laserBeam = Paint()
        ..color = (isHovered ? Colors.white : agent.accentColor).withValues(alpha: (isHovered ? 0.90 : 0.40) * depthAlpha)
        ..strokeWidth = isHovered ? 1.8 : 0.9
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center, nodePos, laserBeam);

      // Traveling Photon Comet Spark along the beam
      final double photonProgress = (time * 1.8 + i * 0.33) % 1.0;
      final Offset sparkPos = Offset.lerp(center, nodePos, photonProgress)!;
      final Offset tailPos = Offset.lerp(center, nodePos, (photonProgress - 0.08).clamp(0.0, 1.0))!;

      // Spark Tail
      final Paint tailPaint = Paint()
        ..color = agent.color.withValues(alpha: (isHovered ? 0.8 : 0.45) * depthAlpha)
        ..strokeWidth = isHovered ? 2.5 : 1.5;
      canvas.drawLine(tailPos, sparkPos, tailPaint);

      // Spark Head
      final Paint sparkPaint = Paint()
        ..color = (isHovered ? Colors.white : agent.accentColor)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(sparkPos, isHovered ? 3.5 : 2.2, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CoreHolographicPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.tiltX != tiltX ||
        oldDelegate.tiltY != tiltY ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}
