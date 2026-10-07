import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/permission_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../widgets/gradient_button.dart';
class JourneyPromptCard extends ConsumerStatefulWidget {
  final void Function(String topic, String mode, String level) onStartJourney;

  const JourneyPromptCard({
    super.key,
    required this.onStartJourney,
  });

  @override
  ConsumerState<JourneyPromptCard> createState() => _JourneyPromptCardState();
}

class _JourneyPromptCardState extends ConsumerState<JourneyPromptCard> {
  bool _isHovered = false;
  String _selectedMode = 'Visual 🎬';
  String _selectedLevel = 'Middle School 🏫';
  final TextEditingController _promptController = TextEditingController();

  static const String _deepDiveMode = 'Deep Dive 🔬';
  final List<String> _modes = ['Visual 🎬', _deepDiveMode, 'Bite-Sized ⚡'];
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
    final isDark = AppColors.isDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -2.0 : 0, 0),
        constraints: const BoxConstraints(maxWidth: 840),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        padding: const EdgeInsets.fromLTRB(32, 26, 32, 22),
        decoration: BoxDecoration(
          color: isDark ? AppColors.canvasBackground : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? AppColors.primary.withValues(alpha: _isHovered ? 0.70 : 0.45)
                : (_isHovered
                    ? const Color(0xFFC7D2FE)
                    : const Color(0xFFC7D2FE).withValues(alpha: 0.6)),
            width: 1.5,
          ),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: _isHovered ? 0.32 : 0.20,
                    ),
                    blurRadius: _isHovered ? 48 : 40,
                    spreadRadius: _isHovered ? -4 : -8,
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0x0F0F172A),
                    blurRadius: _isHovered ? 36 : 30,
                    spreadRadius: -4,
                    offset: const Offset(0, 12),
                  ),
                  const BoxShadow(
                    color: Color(0x060F172A),
                    blurRadius: 8,
                    offset: Offset(0, 2),
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
    );
  }

  Widget _buildDropdownRow() {
    final perms = ref.watch(permissionProvider);
    final Set<String> lockedModes = perms.canAccessDeepDiveMode ? {} : {_deepDiveMode};

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
                lockedItems: lockedModes,
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
                lockedItems: lockedModes,
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
    Set<String> lockedItems = const {},
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.isDark ? const Color(0xFF151624) : AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Builder(
            builder: (context) {
              return Theme(
                data: Theme.of(context).copyWith(
                  hoverColor: AppColors.primary.withValues(alpha: 0.12),
                  focusColor: AppColors.primary.withValues(alpha: 0.15),
                  splashColor: AppColors.primary.withValues(alpha: 0.1),
                  highlightColor: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(16),
                    dropdownColor: AppColors.isDark ? const Color(0xFF151624) : AppColors.surface,
                    icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                    style: AppTextStyles.bodyPrimary,
                    items: items.map((String item) {
                      final isLocked = lockedItems.contains(item);
                      return DropdownMenuItem<String>(
                        value: item,
                        enabled: !isLocked,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item,
                                style: isLocked
                                    ? AppTextStyles.bodyPrimary.copyWith(color: AppColors.textMuted)
                                    : null,
                              ),
                            ),
                            if (isLocked) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentAmber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock_rounded, size: 10, color: AppColors.accentAmber),
                                    const SizedBox(width: 3),
                                    Text(
                                      'PRO',
                                      style: AppTextStyles.badge.copyWith(
                                        fontSize: 9,
                                        color: AppColors.accentAmber,
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
                    }).toList(),
                    onChanged: (val) {
                      if (val != null && lockedItems.contains(val)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('🔬 Deep Dive mode unlocks with Pro plan — go deeper into any topic!'),
                            backgroundColor: AppColors.surfaceDark,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        return;
                      }
                      onChanged(val);
                    },
                  ),
                ),
              );
            },
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
                onPressed: () {
                  if (_promptController.text.trim().isNotEmpty) {
                    widget.onStartJourney(
                      _promptController.text.trim(),
                      _selectedMode,
                      _selectedLevel,
                    );
                  }
                },
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
                onPressed: () {
                  if (_promptController.text.trim().isNotEmpty) {
                    widget.onStartJourney(
                      _promptController.text.trim(),
                      _selectedMode,
                      _selectedLevel,
                    );
                  }
                },
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
      style: AppTextStyles.bodyPrimary.copyWith(fontSize: 15),
      maxLines: 1,
      decoration: InputDecoration(
        hintText: 'Ask EduTechAI anything... (e.g., I want to learn Python programming from zero)',
        hintStyle: AppTextStyles.body2.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: AppColors.isDark ? const Color(0xFF151624) : AppColors.surfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSuggestedTopics() {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () {
          // Future popover or bottom sheet
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.adaptiveLavender,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Browse Suggested Topics',
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.adaptiveLavender,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.adaptiveLavender,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
