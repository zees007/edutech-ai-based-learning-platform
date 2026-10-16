import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/constants/responsive.dart';

/// An interactive 3D Holographic AI Blackboard Core centerpiece.
///
/// Features:
/// - True 3D perspective projection with smooth liquid mouse-tilt lerping.
/// - Concentric glowing gyroscopic orbital rings with moving energy sparks.
/// - Dynamic data stream lines connecting orbiting agent satellites to the core with traveling telemetry packets.
/// - Depth-sorting: forward nodes render larger, brighter, and display their identity labels; rear nodes render softly dimmed.
/// - Holographic central quantum core with tech reticle rings and breathing energy shields.
/// - Interactive hover telemetry card showing live agent milestones.
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

  static const List<_AgentOrbitalData> _agents = [
    _AgentOrbitalData(
      icon: '🎯',
      name: 'Orchestrator',
      color: Color(0xFF2B68F6),
      role: 'SUPERVISOR AGENT',
      status: 'Decomposing milestones & prerequisite DAGs',
    ),
    _AgentOrbitalData(
      icon: '💬',
      name: 'Socratic Tutor',
      color: Color(0xFF60A5FA),
      role: 'COGNITIVE GUIDE',
      status: 'Active guided inquiry & everyday analogies',
    ),
    _AgentOrbitalData(
      icon: '🎬',
      name: 'Video Curator',
      color: Color(0xFF00F5D4),
      role: 'VECTOR CLIP LOCATOR',
      status: 'Pinpointing verified YouTube timestamp clips',
    ),
    _AgentOrbitalData(
      icon: '📚',
      name: 'Researcher',
      color: Color(0xFF10B981),
      role: 'ACADEMIC SYNTHESIS',
      status: 'Searching 250M+ arXiv & OpenAlex preprints',
    ),
    _AgentOrbitalData(
      icon: '📝',
      name: 'Quiz Agent',
      color: Color(0xFFF59E0B),
      role: 'GROUNDED EVALUATION',
      status: 'Generating formative checks & instant XP grading',
    ),
    _AgentOrbitalData(
      icon: '⚡',
      name: 'Synthesizer',
      color: Color(0xFFE879F9),
      role: 'BLACKBOARD TELEMETRY',
      status: 'Streaming WebSocket telemetry & Second Brain export',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
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
    final double height = isMobile ? 310 : 420;

    return MouseRegion(
      onHover: _onHover,
      onExit: _onExit,
      child: AnimatedBuilder(
        animation: _orbitController,
        builder: (context, _) {
          // Smooth liquid lerp for mouse tilt
          _mouseX += (_targetMouseX - _mouseX) * 0.08;
          _mouseY += (_targetMouseY - _mouseY) * 0.08;

          final double time = _orbitController.value * 2 * math.pi;

          return SizedBox(
            width: double.infinity,
            height: height,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 1. Gyroscopic Canvas with Data Stream Beams & Tech Reticles
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CoreHolographicPainter(
                      time: time,
                      tiltX: _mouseY * 0.35,
                      tiltY: _mouseX * 0.45,
                      isMobile: isMobile,
                      agents: _agents,
                      hoveredIndex: _hoveredAgentIndex,
                    ),
                  ),
                ),

                // 2. Central Quantum Blackboard Core
                _buildCentralCore(isMobile, time),

                // 3. 3D Projected Agent Satellites
                ..._buildAgentSatellites(time, isMobile),

                // 4. Live Telemetry Status Pill
                Positioned(
                  bottom: 10,
                  child: _buildTelemetryBadge(isMobile),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCentralCore(bool isMobile, double time) {
    final double coreSize = isMobile ? 86 : 116;
    final double pulse = 1.0 + 0.05 * math.sin(time * 2.5);

    return Transform.scale(
      scale: pulse,
      child: Container(
        width: coreSize,
        height: coreSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [
              Colors.white,
              Color(0xFF60A5FA),
              Color(0xFF2B68F6),
              Color(0xFF090A14),
            ],
            stops: [0.0, 0.25, 0.65, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2B68F6).withValues(alpha: 0.55),
              blurRadius: 45,
              spreadRadius: 6,
            ),
            BoxShadow(
              color: const Color(0xFFB838EE).withValues(alpha: 0.35),
              blurRadius: 75,
              spreadRadius: 8,
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.hub_rounded,
                    color: Colors.white,
                    size: isMobile ? 26 : 34,
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'AI CORE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 8.5 : 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
                  ),
                  Text(
                    'BLACKBOARD',
                    style: TextStyle(
                      color: const Color(0xFF00F5D4),
                      fontSize: isMobile ? 6.5 : 7.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAgentSatellites(double time, bool isMobile) {
    final double radiusX = (isMobile ? 140 : 230);
    final double radiusY = (isMobile ? 60 : 92);
    final List<Widget> satellites = [];

    for (int i = 0; i < _agents.length; i++) {
      final agent = _agents[i];
      final double angle = time + (i * 2 * math.pi / _agents.length);

      final double rawX = math.cos(angle) * radiusX;
      final double rawY = math.sin(angle) * radiusY;

      // 3D tilt coordinates
      final double cosTilt = math.cos(_mouseY * 0.4);
      final double rotatedY = rawY * cosTilt + math.sin(_mouseX * 0.4) * 22;

      // Depth perception: z goes from -1 (rear) to +1 (front)
      final double z = math.sin(angle);
      final double depthScale = 0.82 + (z + 1) * 0.22; // 0.82 to 1.26
      final double depthOpacity = 0.50 + (z + 1) * 0.25; // 0.50 to 1.0

      final bool isHovered = _hoveredAgentIndex == i;
      final bool isFront = z > -0.2;

      satellites.add(
        Transform.translate(
          offset: Offset(rawX, rotatedY),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredAgentIndex = i),
            onExit: (_) => setState(() => _hoveredAgentIndex = null),
            cursor: SystemMouseCursors.click,
            child: Opacity(
              opacity: isHovered ? 1.0 : depthOpacity.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: isHovered ? 1.35 : depthScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Node Orb
                    Container(
                      padding: EdgeInsets.all(isMobile ? 9 : 12),
                      decoration: BoxDecoration(
                        color: const Color(0xEE090A14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isHovered
                              ? Colors.white
                              : agent.color.withValues(alpha: 0.75),
                          width: isHovered ? 2.0 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: agent.color.withValues(
                              alpha: isHovered ? 0.75 : 0.35,
                            ),
                            blurRadius: isHovered ? 24 : 14,
                            spreadRadius: isHovered ? 3 : 0,
                          ),
                        ],
                      ),
                      child: Text(
                        agent.icon,
                        style: TextStyle(fontSize: isMobile ? 18 : 22),
                      ),
                    ),

                    // Label badge (only for front nodes or hovered)
                    if (isFront || isHovered) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xDD090A14),
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(
                            color: agent.color.withValues(alpha: isHovered ? 0.9 : 0.4),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          agent.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 9.5 : 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return satellites;
  }

  Widget _buildTelemetryBadge(bool isMobile) {
    final activeAgent = _hoveredAgentIndex != null
        ? _agents[_hoveredAgentIndex!]
        : null;

    final String title = activeAgent != null
        ? '${activeAgent.icon} ${activeAgent.name}'
        : '⚡ BLACKBOARD STATE VECTOR';
    final String subtitle = activeAgent != null
        ? activeAgent.status
        : '6 Autonomous agents streaming synchronized state at 60 FPS';
    final Color badgeColor = activeAgent?.color ?? const Color(0xFF00F5D4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xEE090A14),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: badgeColor,
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFFEEF0F6),
              fontSize: isMobile ? 11 : 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '•  $subtitle',
            style: TextStyle(
              color: const Color(0xFFB9BECF),
              fontSize: isMobile ? 10 : 11.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentOrbitalData {
  final String icon;
  final String name;
  final Color color;
  final String role;
  final String status;

  const _AgentOrbitalData({
    required this.icon,
    required this.name,
    required this.color,
    required this.role,
    required this.status,
  });
}

/// CustomPainter rendering 3D gyroscopic rings, connection data beams, and packet sparks
class _CoreHolographicPainter extends CustomPainter {
  final double time;
  final double tiltX;
  final double tiltY;
  final bool isMobile;
  final List<_AgentOrbitalData> agents;
  final int? hoveredIndex;

  _CoreHolographicPainter({
    required this.time,
    required this.tiltX,
    required this.tiltY,
    required this.isMobile,
    required this.agents,
    required this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double radiusX = (isMobile ? 140 : 230);
    final double radiusY = (isMobile ? 60 : 92);

    // ─── 1. Draw Connecting Data Streams (Beams) from Core to Satellites ───
    for (int i = 0; i < agents.length; i++) {
      final agent = agents[i];
      final double angle = time + (i * 2 * math.pi / agents.length);

      final double rawX = math.cos(angle) * radiusX;
      final double rawY = math.sin(angle) * radiusY;
      final double cosTilt = math.cos(tiltX);
      final double rotatedY = rawY * cosTilt + math.sin(tiltY) * 22;

      final Offset nodePos = Offset(center.dx + rawX, center.dy + rotatedY);

      final double z = math.sin(angle);
      final double depthAlpha = ((z + 1) * 0.5).clamp(0.2, 0.85);

      final Paint beamPaint = Paint()
        ..color = agent.color.withValues(alpha: 0.18 * depthAlpha)
        ..strokeWidth = (i == hoveredIndex) ? 2.0 : 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(center, nodePos, beamPaint);

      // Moving Data Packet Spark along the beam
      final double packetProgress = (time * 1.5 + i * 0.35) % 1.0;
      final Offset sparkPos = Offset.lerp(center, nodePos, packetProgress)!;

      final Paint sparkPaint = Paint()
        ..color = (i == hoveredIndex ? Colors.white : agent.color)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(sparkPos, i == hoveredIndex ? 3.0 : 2.0, sparkPaint);
    }

    // ─── 2. Concentric Gyroscopic Rings ───
    // Ring 1: Main Elliptical Orbit
    final Paint ring1Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF2B68F6).withValues(alpha: 0.05),
          const Color(0xFF00F5D4).withValues(alpha: 0.65),
          const Color(0xFF7C3AED).withValues(alpha: 0.75),
          const Color(0xFF2B68F6).withValues(alpha: 0.05),
        ],
        transform: GradientRotation(time * 0.8),
      ).createShader(Rect.fromCircle(center: center, radius: 240));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tiltY * 0.5);
    canvas.scale(1.0, (isMobile ? 0.42 : 0.40) + tiltX * 0.2);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: isMobile ? 280 : 460,
        height: isMobile ? 280 : 460,
      ),
      ring1Paint,
    );
    canvas.restore();

    // Ring 2: Counter-Rotating Equatorial Ring
    final Paint ring2Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = SweepGradient(
        colors: [
          const Color(0xFFE879F9).withValues(alpha: 0.05),
          const Color(0xFFE879F9).withValues(alpha: 0.55),
          const Color(0xFF60A5FA).withValues(alpha: 0.65),
          const Color(0xFFE879F9).withValues(alpha: 0.05),
        ],
        transform: GradientRotation(-time * 1.1),
      ).createShader(Rect.fromCircle(center: center, radius: 200));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-tiltY * 0.7 + math.pi / 4);
    canvas.scale(1.0, 0.44 - tiltX * 0.15);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: isMobile ? 190 : 300,
        height: isMobile ? 190 : 300,
      ),
      ring2Paint,
    );
    canvas.restore();

    // Ring 3: Fine Rotating Tech Reticle Ring
    final Paint ring3Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.12);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(time * 0.2);
    canvas.scale(1.0, 0.32);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: isMobile ? 340 : 540,
        height: isMobile ? 340 : 540,
      ),
      ring3Paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CoreHolographicPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.tiltX != tiltX ||
        oldDelegate.tiltY != tiltY ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}
