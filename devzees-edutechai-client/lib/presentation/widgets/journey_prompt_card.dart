import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_button.dart';

class JourneyPromptCard extends StatefulWidget {
  final VoidCallback onStartJourney;

  const JourneyPromptCard({
    super.key,
    required this.onStartJourney,
  });

  @override
  State<JourneyPromptCard> createState() => _JourneyPromptCardState();
}

class _JourneyPromptCardState extends State<JourneyPromptCard> {
  bool _isHovered = false;
  String _selectedMode = 'Visual 🎬';
  String _selectedLevel = 'Middle School 🏫';
  final TextEditingController _promptController = TextEditingController();

  final List<String> _modes = ['Visual 🎬', 'Deep Dive 🔬', 'Bite-Sized ⚡'];
  final List<String> _levels = [
    'Middle School 🏫',
    'High School 🎒',
    'Undergraduate 🏛️',
    'Graduate 🎓',
    'General Curious 💡'
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -2.0 : 0, 0),
        constraints: const BoxConstraints(maxWidth: 840),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // Main Glass Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? const Color(0x8CA855F7) // 0.55 alpha
                        : const Color(0x59A855F7), // 0.35 alpha
                    offset: _isHovered ? const Offset(0, 30) : const Offset(0, 25),
                    blurRadius: _isHovered ? 75 : 65,
                    spreadRadius: _isHovered ? -10 : -15,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.fromLTRB(35, 28, 35, 22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xF00F172A), // rgba(15, 23, 42, 0.94)
                          Color(0xE61A112E), // rgba(26, 17, 46, 0.9)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: _isHovered
                            ? const Color(0xD9A855F7) // rgba(168, 85, 247, 0.85)
                            : const Color(0x73A855F7), // rgba(168, 85, 247, 0.45)
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _isHovered
                              ? const Color(0x33A855F7) // 0.2 alpha
                              : const Color(0x1EA855F7), // 0.12 alpha
                          blurRadius: _isHovered ? 45 : 35,
                          blurStyle: BlurStyle.inner,
                        ),
                      ],
                    ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row 1: Dropdowns
                      _buildDropdownRow(),
                      const SizedBox(height: 16),
                      // Row 2: Chat Input and Button
                      _buildInputRow(),
                      const SizedBox(height: 16),
                      // Row 3: Suggested Topics
                      _buildSuggestedTopics(),
                    ],
                  ),
                ),
              ),
            ),
            ),
            // Top Glowing Neon Bar (The ::before pseudo-element)
            Positioned(
              top: 0,
              left: 40,
              right: 40,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isHovered ? 1.0 : 0.8,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.accentPink,
                        AppColors.primary,
                        AppColors.accentBlue,
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPink,
                        blurRadius: _isHovered ? 22 : 15,
                      ),
                      BoxShadow(
                        color: AppColors.primary,
                        blurRadius: _isHovered ? 30 : 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        
        if (isMobile) {
          return Column(
            children: [
              _buildCustomDropdown(
                label: '🎨 Learning Mode',
                value: _selectedMode,
                items: _modes,
                onChanged: (val) => setState(() => _selectedMode = val!),
              ),
              const SizedBox(height: 12),
              _buildCustomDropdown(
                label: '🎓 Education Level',
                value: _selectedLevel,
                items: _levels,
                onChanged: (val) => setState(() => _selectedLevel = val!),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildCustomDropdown(
                label: '🎨 Learning Mode',
                value: _selectedMode,
                items: _modes,
                onChanged: (val) => setState(() => _selectedMode = val!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCustomDropdown(
                label: '🎓 Education Level',
                value: _selectedLevel,
                items: _levels,
                onChanged: (val) => setState(() => _selectedLevel = val!),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1B1728), // Darker dropdown bg
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(),
              const SizedBox(height: 12),
              GradientButton(
                text: '✨ Start Journey',
                onPressed: widget.onStartJourney,
                height: 52,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 5,
              child: _buildTextField(),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GradientButton(
                text: '✨ Start Journey',
                onPressed: widget.onStartJourney,
                height: 54, // Matches text field height approx
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: _promptController,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
      maxLines: 1,
      decoration: InputDecoration(
        hintText: 'Ask EduTechAI anything... (e.g., I want to learn Python programming from zero)',
        hintStyle: GoogleFonts.inter(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildSuggestedTopics() {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () {
          // TODO: Implement popover or bottom sheet
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFE9D5FF),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Browse Suggested Topics',
                style: GoogleFonts.inter(
                  color: const Color(0xFFE9D5FF),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFFE9D5FF),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
