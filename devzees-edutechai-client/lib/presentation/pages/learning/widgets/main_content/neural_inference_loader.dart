import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../widgets/animated_tutor_icon.dart';
import '../../../../../core/constants/responsive.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 650;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 850),
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 16 : 24,
                ),
                padding: EdgeInsets.all(isMobile ? 18 : 24),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF11121D).withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? AppColors.primary.withValues(alpha: 0.65)
                        : const Color(0xFFA855F7).withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (isDark) ...[
                      // Deep background drop shadow
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.55),
                        blurRadius: 36,
                        offset: const Offset(0, 18),
                      ),
                      if (!isMobile) ...[
                        // Vibrant neon border rim glow
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.38),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                        // Broad ambient primary glow
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 45,
                          spreadRadius: 6,
                        ),
                        // Deep neon atmospheric halo
                        BoxShadow(
                          color: const Color(0xFF1D4ED8).withValues(alpha: 0.15),
                          blurRadius: 80,
                          spreadRadius: 12,
                        ),
                      ],
                    ] else ...[
                      // Light mode refined shadows & luminous violet atmospheric aura
                      BoxShadow(
                        color: const Color(0x1A000000),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                      if (!isMobile) ...[
                        BoxShadow(
                          color: const Color(0xFFA855F7).withValues(alpha: 0.12),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                          blurRadius: 36,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.05),
                          blurRadius: 60,
                          spreadRadius: 8,
                        ),
                      ],
                    ],
                  ],
                ),
                child: isMobile
                    ? _buildMobileContent(isDark: isDark)
                    : _buildDesktopContent(isDark: isDark),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Mobile Compact View: Fits comfortably in a single screen (<400px height) without scrolling
  Widget _buildMobileContent({required bool isDark}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Cluster Bar + Live Inference Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GradientSpinner(
                    size: 11,
                    backgroundColor: isDark
                        ? const Color(0xFF11121D)
                        : Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'AI COMPUTE CLUSTER',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : AppColors.slate500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            _buildLiveInferenceBadge(isMobile: true, isDark: isDark),
          ],
        ),
        const SizedBox(height: 12),

        // Compact Gradient Title
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDark
                ? const [Color(0xFFEC4899), Color(0xFFA855F7)]
                : const [Color(0xFFBE185D), Color(0xFF7C3AED)],
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
            color: isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        // Centered Glowing Neural Core
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Center(
            child: SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing ambient halo
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 52 + 8 * _pulseController.value,
                        height: 52 + 8 * _pulseController.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (!Responsive.isMobile(context)) ...[
                              BoxShadow(
                                color: (isDark ? AppColors.primary : const Color(0xFFA855F7)).withValues(
                                  alpha: isDark
                                      ? (0.35 + 0.20 * _pulseController.value)
                                      : (0.16 + 0.10 * _pulseController.value),
                                ),
                                blurRadius: 22,
                                spreadRadius: 3,
                              ),
                              BoxShadow(
                                color: const Color(0xFFEC4899).withValues(
                                  alpha: isDark
                                      ? (0.20 + 0.15 * _pulseController.value)
                                      : (0.10 + 0.08 * _pulseController.value),
                                ),
                                blurRadius: 32,
                                spreadRadius: 1,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  // Rotating Gradient Spinner Ring
                  GradientSpinner(
                    size: 52,
                    backgroundColor: isDark
                        ? const Color(0xFF11121D)
                        : Colors.white,
                  ),
                  // Inner Socratic Tutor Animated Icon
                  const AnimatedTutorIcon(size: 34, showHalo: false),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Progress Bar
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 6,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: constraints.maxWidth * widget.progressPercent,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [
                            Color(0xFFEC4899),
                            Color(0xFFA855F7),
                            Color(0xFF06B6D4),
                          ]
                        : const [
                            Color(0xFFDB2777),
                            Color(0xFF7C3AED),
                            Color(0xFF0284C7),
                          ],
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
                  isDark: isDark,
                ),
                _buildMobileAgentChip(
                  icon: '💬',
                  name: 'Socratic Tutor',
                  status: 'active',
                  width: chipWidth,
                  isDark: isDark,
                ),
                _buildMobileAgentChip(
                  icon: '📺',
                  name: 'YouTube Curator',
                  status: 'active',
                  width: chipWidth,
                  isDark: isDark,
                ),
                _buildMobileAgentChip(
                  icon: '📚',
                  name: 'Researcher',
                  status: 'active',
                  width: chipWidth,
                  isDark: isDark,
                ),
                _buildMobileAgentChip(
                  icon: '📝',
                  name: 'Quiz Agent',
                  status: 'active',
                  width: chipWidth,
                  isDark: isDark,
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
    required bool isDark,
  }) {
    final bool isCompleted = status == 'completed';
    final bool isActive = status == 'active';

    Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0);
    Color bgColor = isDark
        ? const Color(0xFF151624).withValues(alpha: 0.7)
        : const Color(0xFFF8FAFC);
    List<BoxShadow> shadows = [];

    if (isActive) {
      borderColor = (isDark ? AppColors.primary : const Color(0xFFA855F7))
          .withValues(alpha: isDark ? 0.45 : 0.50);
      bgColor = isDark
          ? AppColors.primary.withValues(alpha: 0.08)
          : const Color(0xFFF5F3FF);
      shadows = [
        BoxShadow(
          color: (isDark ? AppColors.primary : const Color(0xFFA855F7))
              .withValues(alpha: isDark ? 0.16 : 0.10),
          blurRadius: 8,
        ),
      ];
    } else if (isCompleted) {
      borderColor = const Color(0xFF10B981).withValues(alpha: isDark ? 0.45 : 0.50);
      bgColor = isDark
          ? const Color(0xFF10B981).withValues(alpha: 0.08)
          : const Color(0xFFF0FDF4);
      shadows = [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.10),
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
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.4 : 0.35),
                ),
              ),
              child: Text(
                '✓ Done',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                ),
              ),
            )
          else if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primary : const Color(0xFFA855F7))
                    .withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: (isDark ? AppColors.primary : const Color(0xFFA855F7))
                      .withValues(alpha: isDark ? 0.45 : 0.40),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GradientSpinner(
                    size: 8,
                    backgroundColor: isDark
                        ? const Color(0xFF151624)
                        : const Color(0xFFF5F3FF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Active',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF7C3AED),
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
  Widget _buildDesktopContent({required bool isDark}) {
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
                    GradientSpinner(
                      size: 14,
                      backgroundColor: isDark
                          ? const Color(0xFF11121D)
                          : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'EDU-TECH AI COMPUTE CLUSTER  •  NEURAL INFERENCE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : AppColors.slate500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: isDark
                        ? const [Color(0xFFEC4899), Color(0xFFA855F7)]
                        : const [Color(0xFFBE185D), Color(0xFF7C3AED)],
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
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: _buildLiveInferenceBadge(isMobile: false, isDark: isDark),
            ),
          ],
        ),

        const SizedBox(height: 24),
        Divider(color: AppColors.border, height: 1),
        const SizedBox(height: 24),

        // Neural Network Canvas
        LayoutBuilder(
          builder: (context, constraints) {
            final double canvasWidth = constraints.maxWidth;
            const double canvasHeight = 190.0;

            return Container(
              width: double.infinity,
              height: canvasHeight + 36,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF151624)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _pulseController,
                    _pulseDotController,
                  ]),
                  builder: (context, child) => Transform.scale(
                    scale: 0.97 + (_pulseDotController.value * 0.03),
                    child: CustomPaint(
                      size: Size(canvasWidth, canvasHeight),
                      painter: NeuralNetworkPainter(
                        animationValue: _pulseController.value,
                        isDark: isDark,
                      ),
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
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: constraints.maxWidth * widget.progressPercent,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [
                            Color(0xFFEC4899),
                            Color(0xFFA855F7),
                            Color(0xFF06B6D4),
                          ]
                        : const [
                            Color(0xFFDB2777),
                            Color(0xFF7C3AED),
                            Color(0xFF0284C7),
                          ],
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
                  desc:
                      'Decomposing topic into structured, age-appropriate milestone roadmap.',
                  status: 'completed',
                  width: cardWidth,
                  isMobile: false,
                  isDark: isDark,
                ),
                _buildAgentCard(
                  name: '💬 Socratic Tutor',
                  desc:
                      'Crafting deep intuitive explanations & interactive guiding questions.',
                  status: 'active',
                  width: cardWidth,
                  isMobile: false,
                  isDark: isDark,
                ),
                _buildAgentCard(
                  name: '📺 YouTube Curator',
                  desc:
                      'Filtering high-yield educational videos with precise timestamp deep-linking.',
                  status: 'active',
                  width: cardWidth,
                  isMobile: false,
                  isDark: isDark,
                ),
                _buildAgentCard(
                  name: '📚 Academic Researcher',
                  desc:
                      'Indexing peer-reviewed open access papers from OpenAlex & Semantic Scholar.',
                  status: 'active',
                  width: cardWidth,
                  isMobile: false,
                  isDark: isDark,
                ),
                _buildAgentCard(
                  name: '📝 Quiz Agent',
                  desc:
                      'Structuring adaptive comprehension questions & XP reward multipliers.',
                  status: 'active',
                  width: cardWidth,
                  isMobile: false,
                  isDark: isDark,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLiveInferenceBadge({
    required bool isMobile,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 10,
        vertical: isMobile ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.45 : 0.40),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.18 : 0.12),
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
                      blurRadius:
                          (isMobile ? 6 : 8) * _pulseDotController.value,
                      spreadRadius:
                          (isMobile ? 1.5 : 2) * _pulseDotController.value,
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
              color: isDark ? const Color(0xFF10B981) : const Color(0xFF047857),
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
    required bool isDark,
  }) {
    final bool isActive = status == 'active';
    final bool isCompleted = status == 'completed';

    Color bgColor = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : const Color(0xFFF8FAFC);
    Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE2E8F0);
    List<BoxShadow> shadows = [];

    if (isActive) {
      bgColor = isDark
          ? AppColors.primary.withValues(alpha: 0.06)
          : const Color(0xFFF5F3FF);
      borderColor = (isDark ? AppColors.primary : const Color(0xFFA855F7))
          .withValues(alpha: isDark ? 0.45 : 0.45);
      shadows = [
        BoxShadow(
          color: (isDark ? AppColors.primary : const Color(0xFFA855F7))
              .withValues(alpha: isDark ? 0.18 : 0.10),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    } else if (isCompleted) {
      bgColor = isDark
          ? const Color(0xFF10B981).withValues(alpha: 0.05)
          : const Color(0xFFF0FDF4);
      borderColor = const Color(0xFF10B981).withValues(alpha: isDark ? 0.4 : 0.45);
      shadows = [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.12 : 0.10),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    } else if (!isDark) {
      shadows = [
        BoxShadow(
          color: const Color(0x06000000),
          blurRadius: 8,
          offset: const Offset(0, 2),
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
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusTag(status, isMobile: isMobile, isDark: isDark),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: isMobile ? 11 : 12,
              color: isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(
    String status, {
    required bool isMobile,
    required bool isDark,
  }) {
    if (status == 'completed') {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 6 : 8,
          vertical: isMobile ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.15 : 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.4 : 0.35),
          ),
        ),
        child: Text(
          '✓ COMPLETED',
          style: GoogleFonts.inter(
            fontSize: isMobile ? 9 : 10,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
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
          color: (isDark ? AppColors.primary : const Color(0xFFA855F7))
              .withValues(alpha: isDark ? 0.18 : 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDark ? AppColors.primary : const Color(0xFFA855F7))
                .withValues(alpha: isDark ? 0.45 : 0.40),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientSpinner(
              size: isMobile ? 9 : 10,
              backgroundColor: isDark
                  ? const Color(0xFF11121D)
                  : const Color(0xFFF5F3FF),
            ),
            SizedBox(width: isMobile ? 4 : 6),
            Text(
              'EXECUTING...',
              style: GoogleFonts.inter(
                fontSize: isMobile ? 9 : 10,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF7C3AED),
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
  final Color? backgroundColor;

  const GradientSpinner({
    super.key,
    required this.size,
    this.backgroundColor,
  });

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? const Color(0xFF11121D) : Colors.white;

    return RotationTransition(
      turns: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [Color(0xFF3B82F6), Color(0xFFEC4899), Colors.transparent],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.backgroundColor ?? defaultBg,
            ),
          ),
        ),
      ),
    );
  }
}

class NeuralNetworkPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;

  NeuralNetworkPainter({
    required this.animationValue,
    this.isDark = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Map of node coordinates (matching base coordinates 800 x 190)
    // Scale X and Y to fit available size
    final scaleX = size.width / 800;
    final scaleY = size.height / 190;

    Offset getPt(double x, double y) {
      return Offset(x * scaleX, y * scaleY);
    }

    // Nodes with comfortable vertical clearance (Y range: 32 -> 140)
    final topic = getPt(80, 48);
    final contextNode = getPt(80, 136);

    final orchestrator = getPt(280, 32);
    final roadmap = getPt(280, 92);
    final vectorRag = getPt(280, 152);

    final socratic = getPt(520, 32);
    final youtube = getPt(520, 92);
    final academic = getPt(520, 152);

    final workspace = getPt(720, 92);

    // Draw lines
    final paintLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    void drawLine(Offset p1, Offset p2, Color color) {
      paintLine.color = color;
      canvas.drawLine(p1, p2, paintLine);
    }

    final pinkLine = (isDark ? const Color(0xFFEC4899) : const Color(0xFFDB2777))
        .withValues(alpha: isDark ? 0.35 : 0.45);
    final purpleLine = (isDark ? const Color(0xFFA855F7) : const Color(0xFF7C3AED))
        .withValues(alpha: isDark ? 0.40 : 0.45);
    final blueLine = (isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB))
        .withValues(alpha: isDark ? 0.40 : 0.45);
    final cyanLine = (isDark ? const Color(0xFF06B6D4) : const Color(0xFF0891B2))
        .withValues(alpha: isDark ? 0.40 : 0.45);
    final greenLine = (isDark ? const Color(0xFF10B981) : const Color(0xFF059669))
        .withValues(alpha: isDark ? 0.40 : 0.45);

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

    // Flow from left to middle
    pulsePaint.color = isDark ? const Color(0xFFEC4899) : const Color(0xFFDB2777);
    canvas.drawCircle(lerp(topic, orchestrator, animationValue), 4, pulsePaint);
    canvas.drawCircle(
      lerp(contextNode, vectorRag, (animationValue + 0.2) % 1.0),
      4,
      pulsePaint,
    );
    canvas.drawCircle(
      lerp(topic, roadmap, (animationValue + 0.5) % 1.0),
      4,
      pulsePaint,
    );
    canvas.drawCircle(
      lerp(contextNode, roadmap, (animationValue + 0.8) % 1.0),
      4,
      pulsePaint,
    );

    // Flow from middle to right
    pulsePaint.color = isDark ? const Color(0xFFA855F7) : const Color(0xFF7C3AED);
    canvas.drawCircle(
      lerp(orchestrator, socratic, (animationValue + 0.1) % 1.0),
      4,
      pulsePaint,
    );
    canvas.drawCircle(
      lerp(roadmap, youtube, (animationValue + 0.4) % 1.0),
      4,
      pulsePaint,
    );
    canvas.drawCircle(
      lerp(vectorRag, academic, (animationValue + 0.7) % 1.0),
      4,
      pulsePaint,
    );

    // Flow from right to Workspace
    pulsePaint.color = isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);
    canvas.drawCircle(
      lerp(socratic, workspace, (animationValue + 0.3) % 1.0),
      4,
      pulsePaint,
    );
    canvas.drawCircle(
      lerp(youtube, workspace, (animationValue + 0.6) % 1.0),
      4,
      pulsePaint,
    );
    canvas.drawCircle(
      lerp(academic, workspace, (animationValue + 0.9) % 1.0),
      4,
      pulsePaint,
    );

    // Draw Nodes with luminous aura
    void drawNode(
      Offset pt,
      double r,
      Color strokeColor,
      Color labelColor,
      String emoji,
      String label,
      double strokeW, {
      bool isCore = false,
    }) {
      // Ambient glow ring behind node
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = strokeColor.withValues(
          alpha: isCore ? (isDark ? 0.45 : 0.25) : (isDark ? 0.22 : 0.15),
        )
        ..strokeWidth = isCore ? 4 + 2 * animationValue : 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(
        pt,
        r + (isCore ? 3 + 2 * animationValue : 2),
        glowPaint,
      );

      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = isDark ? const Color(0xFF0B0C14) : Colors.white;
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = strokeColor
        ..strokeWidth = strokeW;

      canvas.drawCircle(pt, r, fillPaint);
      canvas.drawCircle(pt, r, borderPaint);

      // Emoji in center of node
      final emojiPainter = TextPainter(
        text: TextSpan(
          text: emoji,
          style: TextStyle(fontSize: isCore ? 14 : 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      emojiPainter.paint(
        canvas,
        Offset(pt.dx - emojiPainter.width / 2, pt.dy - emojiPainter.height / 2),
      );

      // Label below node with guaranteed bottom margin
      final labelPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: labelColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      labelPainter.paint(
        canvas,
        Offset(pt.dx - labelPainter.width / 2, pt.dy + r + 4),
      );
    }

    drawNode(
      topic,
      16,
      const Color(0xFFEC4899),
      isDark ? const Color(0xFFEC4899) : const Color(0xFFBE185D),
      '🎯',
      'Topic',
      3,
    );
    drawNode(
      contextNode,
      16,
      const Color(0xFFF43F5E),
      isDark ? const Color(0xFFF43F5E) : const Color(0xFFE11D48),
      '👤',
      'Context',
      3,
    );

    drawNode(
      orchestrator,
      18,
      const Color(0xFFA855F7),
      isDark ? const Color(0xFFA855F7) : const Color(0xFF7C3AED),
      '🧠',
      'Orchestrator',
      3,
      isCore: true,
    );
    drawNode(
      roadmap,
      15,
      const Color(0xFF8B5CF6),
      isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6D28D9),
      '⚡',
      'Roadmap',
      3,
    );
    drawNode(
      vectorRag,
      15,
      const Color(0xFF7C3AED),
      isDark ? const Color(0xFF7C3AED) : const Color(0xFF5B21B6),
      '📊',
      'Vector RAG',
      3,
    );

    drawNode(
      socratic,
      16,
      const Color(0xFF3B82F6),
      isDark ? const Color(0xFF3B82F6) : const Color(0xFF1D4ED8),
      '💬',
      'Socratic',
      3,
    );
    drawNode(
      youtube,
      16,
      const Color(0xFF06B6D4),
      isDark ? const Color(0xFF06B6D4) : const Color(0xFF0E7490),
      '📺',
      'YouTube',
      3,
    );
    drawNode(
      academic,
      16,
      const Color(0xFF10B981),
      isDark ? const Color(0xFF10B981) : const Color(0xFF047857),
      '📚',
      'Academic',
      3,
    );

    drawNode(
      workspace,
      22,
      const Color(0xFFEC4899),
      isDark ? const Color(0xFFEC4899) : const Color(0xFFBE185D),
      '🎓',
      'Workspace',
      4,
      isCore: true,
    );
  }

  @override
  bool shouldRepaint(covariant NeuralNetworkPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isDark != isDark;
  }
}
