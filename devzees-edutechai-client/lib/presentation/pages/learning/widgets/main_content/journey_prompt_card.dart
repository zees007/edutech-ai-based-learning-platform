import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/permission_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../widgets/gradient_button.dart';
import '../../../../widgets/gradient_text.dart';

class JourneyPromptCard extends ConsumerStatefulWidget {
  final void Function(String topic, String mode, String level) onStartJourney;

  const JourneyPromptCard({super.key, required this.onStartJourney});

  @override
  ConsumerState<JourneyPromptCard> createState() => _JourneyPromptCardState();
}

class _JourneyPromptCardState extends ConsumerState<JourneyPromptCard> {
  bool _isCardHovered = false;
  bool _isInputHovered = false;
  bool _isInputFocused = false;
  bool _isExpanded = false;

  String _selectedMode = 'Visual 🎬';
  String _selectedLevel = 'Middle School 🏫';
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _collapsedFocusNode = FocusNode();
  final FocusNode _expandedFocusNode = FocusNode();

  static const String _deepDiveMode = 'Deep Dive 🔬';
  final List<String> _modes = ['Visual 🎬', _deepDiveMode, 'Bite-Sized ⚡'];
  final List<String> _levels = [
    'Middle School 🏫',
    'High School 🎒',
    'Undergraduate 🏛️',
    'Graduate 🎓',
    'General Curious 💡',
  ];

  @override
  void initState() {
    super.initState();
    _promptController.addListener(_onPromptChanged);
    _collapsedFocusNode.addListener(_onFocusChanged);
    _expandedFocusNode.addListener(_onFocusChanged);
  }

  void _onPromptChanged() {
    setState(() {});
  }

  void _onFocusChanged() {
    setState(() {
      _isInputFocused =
          _collapsedFocusNode.hasFocus || _expandedFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _promptController.removeListener(_onPromptChanged);
    _collapsedFocusNode.removeListener(_onFocusChanged);
    _expandedFocusNode.removeListener(_onFocusChanged);
    _promptController.dispose();
    _collapsedFocusNode.dispose();
    _expandedFocusNode.dispose();
    super.dispose();
  }

  void _expandInput() {
    setState(() {
      _isExpanded = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _expandedFocusNode.requestFocus();
      }
    });
  }

  void _collapseInput() {
    setState(() {
      _isExpanded = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _collapsedFocusNode.requestFocus();
      }
    });
  }

  void _handleStartJourney() {
    final text = _promptController.text.trim();
    if (text.isNotEmpty) {
      widget.onStartJourney(
        text,
        _selectedMode,
        _selectedLevel,
      );
    } else {
      if (_isExpanded) {
        _expandedFocusNode.requestFocus();
      } else {
        _collapsedFocusNode.requestFocus();
      }
    }
  }

  bool _checkHasMoreThan3Lines(double availableWidth) {
    final text = _promptController.text;
    if (text.isEmpty) return false;

    // Explicit newlines: 3 newlines mean 4 or more lines
    final newlineCount = '\n'.allMatches(text).length;
    if (newlineCount >= 3) return true;

    // Visual soft-wrapped line count using TextPainter
    if (availableWidth > 50) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: AppTextStyles.bodyPrimary.copyWith(
            fontSize: 15,
            height: 1.45,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: availableWidth);
      final lineCount = textPainter.computeLineMetrics().length;
      textPainter.dispose();
      if (lineCount > 3) return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isCardHovered = true),
      onExit: (_) => setState(() => _isCardHovered = false),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isCardHovered ? -2.0 : 0, 0),
          constraints: const BoxConstraints(maxWidth: 840),
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.canvasBackground : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withValues(
                alpha: isDark
                    ? (_isCardHovered ? 0.70 : 0.45)
                    : (_isCardHovered ? 0.70 : 0.40),
              ),
              width: 1.5,
            ),
            boxShadow: [
              // Symmetrical neon primary glow
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: isDark
                      ? (_isCardHovered ? 0.32 : 0.20)
                      : (_isCardHovered ? 0.30 : 0.16),
                ),
                blurRadius: _isCardHovered ? 48 : 40,
                spreadRadius: _isCardHovered ? 2 : 0,
              ),
              if (!isDark)
                BoxShadow(
                  color: const Color(0x0A0F172A),
                  blurRadius: _isCardHovered ? 20 : 12,
                  spreadRadius: -2,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 480;
              final isMobile = constraints.maxWidth < 600;
              final availableWidth = constraints.maxWidth - 36;
              final hasMoreThan3Lines = _checkHasMoreThan3Lines(availableWidth);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown row: visible only when collapsed
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => SizeTransition(
                      sizeFactor: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: !_isExpanded
                        ? Column(
                            key: const ValueKey('dropdowns_visible'),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDropdownRow(isMobile),
                              const SizedBox(height: 12),
                            ],
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('dropdowns_hidden'),
                          ),
                  ),
                  // The input container: same background, same width, expands on top
                  _buildInputContainer(
                    isCompact: isCompact,
                    isMobile: isMobile,
                    hasMoreThan3Lines: hasMoreThan3Lines,
                  ),
                  const SizedBox(height: 10),
                  // Row 3: Browse Suggested Topics (matching previous design with GradientText)
                  _buildSuggestedTopics(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownRow(bool isMobile) {
    final perms = ref.watch(permissionProvider);
    final Set<String> lockedModes = perms.canAccessDeepDiveMode
        ? {}
        : {_deepDiveMode};

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
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.chipBackground,
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
                    dropdownColor: AppColors.cardBackground,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
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
                                    ? AppTextStyles.bodyPrimary.copyWith(
                                        color: AppColors.textMuted,
                                      )
                                    : null,
                              ),
                            ),
                            if (isLocked) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accentAmber.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.accentAmber.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_rounded,
                                      size: 10,
                                      color: AppColors.accentAmber,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'PRO',
                                      style: TextStyle(
                                        color: AppColors.accentAmber,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
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
                      if (lockedItems.contains(val)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              '🔬 Deep Dive mode unlocks with Pro plan — go deeper into any topic!',
                            ),
                            backgroundColor: AppColors.surfaceDark,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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

  /// Unified input container:
  /// - Shares the exact same background in both collapsed & expanded states.
  /// - Expands in-place on the top with the exact same width.
  /// - Dedicated FocusNode for each mode guarantees typing is never blocked.
  /// - Enter press inserts a newline; never sends prompt or starts journey.
  Widget _buildInputContainer({
    required bool isCompact,
    required bool isMobile,
    required bool hasMoreThan3Lines,
  }) {
    final isDark = AppColors.isDark;
    final expandedHeight = isMobile ? 280.0 : 340.0;
    final perms = ref.watch(permissionProvider);
    final Set<String> lockedModes = perms.canAccessDeepDiveMode
        ? {}
        : {_deepDiveMode};

    return MouseRegion(
      onEnter: (_) => setState(() => _isInputHovered = true),
      onExit: (_) => setState(() => _isInputHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: _isExpanded ? expandedHeight : null,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1F2E) : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isInputFocused
                ? AppColors.primary
                : (_isInputHovered
                    ? AppColors.primary.withValues(alpha: 0.55)
                    : AppColors.border),
            width: _isInputFocused ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (_isInputFocused)
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.30 : 0.15,
                ),
                blurRadius: 16,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: _isExpanded ? MainAxisSize.max : MainAxisSize.min,
              children: [
                // Text input area: expanded fills available height; collapsed sizes 1-3 lines
                if (_isExpanded)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 44, 6),
                      child: Focus(
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent &&
                              event.logicalKey == LogicalKeyboardKey.escape) {
                            _collapseInput();
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                        child: ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.dragged) ||
                                  states.contains(WidgetState.hovered)) {
                                return AppColors.primary.withValues(
                                  alpha: 0.85,
                                );
                              }
                              return isDark
                                  ? const Color(0xFF475569)
                                      .withValues(alpha: 0.70)
                                  : const Color(0xFFCBD5E1)
                                      .withValues(alpha: 0.90);
                            }),
                            radius: const Radius.circular(6),
                            thickness: WidgetStateProperty.all(6.0),
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: TextField(
                              controller: _promptController,
                              focusNode: _expandedFocusNode,
                              maxLines: null,
                              expands: true,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              style: AppTextStyles.bodyPrimary.copyWith(
                                fontSize: 15,
                                height: 1.5,
                              ),
                              cursorColor: AppColors.primary,
                              decoration: InputDecoration(
                                hintText:
                                    'Ask EduTechAI anything... (e.g., I want to learn Python programming from zero)',
                                hintStyle: AppTextStyles.body2.copyWith(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontSize: 14.5,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      14,
                      hasMoreThan3Lines ? 44 : 18,
                      6,
                    ),
                    child: TextField(
                      controller: _promptController,
                      focusNode: _collapsedFocusNode,
                      minLines: 1,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: AppTextStyles.bodyPrimary.copyWith(
                        fontSize: 15,
                        height: 1.45,
                      ),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText:
                            'Ask EduTechAI anything... (e.g., I want to learn Python programming from zero)',
                        hintStyle: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 14.5,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                // Bottom action bar: Dropdowns on left when expanded, Start button on right
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 12, 10),
                  child: Row(
                    children: [
                      if (_isExpanded) ...[
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _CompactThemeDropdown(
                                  value: _selectedMode,
                                  items: _modes,
                                  lockedItems: lockedModes,
                                  isMobile: isMobile,
                                  onChanged: (val) =>
                                      setState(() => _selectedMode = val!),
                                ),
                                const SizedBox(width: 8),
                                _CompactThemeDropdown(
                                  value: _selectedLevel,
                                  items: _levels,
                                  isMobile: isMobile,
                                  onChanged: (val) =>
                                      setState(() => _selectedLevel = val!),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ] else ...[
                        const Spacer(),
                      ],
                      GradientButton(
                        text: isCompact ? '✨ Start' : '✨ Start Journey',
                        height: 40,
                        onPressed: _handleStartJourney,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Zoom / Collapse icon strictly at the top-right corner of the input field
            if (_isExpanded || hasMoreThan3Lines)
              Positioned(
                top: 10,
                right: 12,
                child: _ZoomIconButton(
                  isExpanded: _isExpanded,
                  onTap: () {
                    if (_isExpanded) {
                      _collapseInput();
                    } else {
                      _expandInput();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Browse Suggested Topics button with gradient text and interactive popup menu,
  /// preserving the original design.
  Widget _buildSuggestedTopics() {
    final isDark = AppColors.isDark;

    final List<String> suggestions = [
      'I want to learn Python programming from zero step by step 🐍',
      'Explain Deep Neural Networks and Machine Learning 🧠',
      'Intuitive guide to Calculus, Derivatives, and Differential Equations 📐',
      'How does CRISPR-Cas9 Gene Editing and DNA repair work? 🧬',
      'Chemical Bonding: Covalent vs Ionic molecular orbitals ⚗️',
      'Quantum Computing: Qubits and Superposition ⚛️',
    ];

    return Align(
      alignment: Alignment.centerLeft,
      child: Builder(
        builder: (context) {
          return InkWell(
            onTap: () {
              final RenderBox button =
                  context.findRenderObject() as RenderBox;
              final RenderBox overlay = Overlay.of(context)
                  .context
                  .findRenderObject() as RenderBox;
              final RelativeRect position = RelativeRect.fromRect(
                Rect.fromPoints(
                  button.localToGlobal(Offset.zero, ancestor: overlay),
                  button.localToGlobal(
                    button.size.bottomRight(Offset.zero),
                    ancestor: overlay,
                  ),
                ),
                Offset.zero & overlay.size,
              );

              showMenu<String>(
                context: context,
                position: position,
                color: isDark ? const Color(0xFF1E2034) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                elevation: 12,
                items: suggestions.map((topic) {
                  return PopupMenuItem<String>(
                    value: topic,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        topic,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).then((selected) {
                if (selected != null) {
                  _promptController.text = selected;
                  if (_isExpanded) {
                    _expandedFocusNode.requestFocus();
                  } else {
                    _collapsedFocusNode.requestFocus();
                  }
                }
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: isDark ? AppColors.primary : AppColors.purple,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  GradientText(
                    'Browse Suggested Topics',
                    style: AppTextStyles.captionBold.copyWith(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: isDark ? AppColors.primary : AppColors.purple,
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Theme aesthetic compact pill dropdown for the expanded input action bar,
/// matching EduTechAI's neon glow & dark/light palette.
class _CompactThemeDropdown extends StatefulWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Set<String> lockedItems;
  final bool isMobile;

  const _CompactThemeDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.lockedItems = const {},
    this.isMobile = false,
  });

  @override
  State<_CompactThemeDropdown> createState() => _CompactThemeDropdownState();
}

class _CompactThemeDropdownState extends State<_CompactThemeDropdown> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark
              ? (_isHovered ? const Color(0xFF262842) : const Color(0xFF1A1B2C))
              : (_isHovered ? Colors.white : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(
              alpha: isDark
                  ? (_isHovered ? 0.70 : 0.40)
                  : (_isHovered ? 0.60 : 0.35),
            ),
            width: 1.2,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.28 : 0.16,
                ),
                blurRadius: 12,
                spreadRadius: 1,
                offset: Offset.zero,
              ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            hoverColor: AppColors.primary.withValues(alpha: 0.12),
            focusColor: AppColors.primary.withValues(alpha: 0.15),
            splashColor: AppColors.primary.withValues(alpha: 0.10),
            highlightColor: AppColors.primary.withValues(alpha: 0.10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.value,
              borderRadius: BorderRadius.circular(14),
              dropdownColor: isDark ? const Color(0xFF1E2034) : Colors.white,
              elevation: 8,
              icon: Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isDark ? AppColors.primary : AppColors.purple,
                ),
              ),
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: widget.isMobile ? 12 : 13,
              ),
              items: widget.items.map((String item) {
                final isLocked = widget.lockedItems.contains(item);
                return DropdownMenuItem<String>(
                  value: item,
                  enabled: !isLocked,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item,
                        style: isLocked
                            ? AppTextStyles.body2.copyWith(
                                color: AppColors.textMuted,
                                fontSize: widget.isMobile ? 12 : 13,
                              )
                            : AppTextStyles.body2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: widget.isMobile ? 12 : 13,
                              ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentAmber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color:
                                  AppColors.accentAmber.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.lock_rounded,
                                size: 10,
                                color: AppColors.accentAmber,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'PRO',
                                style: TextStyle(
                                  color: AppColors.accentAmber,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
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
                if (widget.lockedItems.contains(val)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        '🔬 Deep Dive mode unlocks with Pro plan — go deeper into any topic!',
                      ),
                      backgroundColor: AppColors.surfaceDark,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  return;
                }
                widget.onChanged(val);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Clean subtle Zoom / Collapse icon strictly for the top-right corner of the input field,
/// matching Google Gemini's prompt box design.
class _ZoomIconButton extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const _ZoomIconButton({
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<_ZoomIconButton> createState() => _ZoomIconButtonState();
}

class _ZoomIconButtonState extends State<_ZoomIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.isExpanded ? 'Collapse prompt' : 'Expand prompt',
        waitDuration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _isHovered
                  ? (isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                widget.isExpanded
                    ? Icons.close_fullscreen_rounded
                    : Icons.open_in_full_rounded,
                size: 16,
                color: _isHovered
                    ? (isDark ? Colors.white : AppColors.textPrimary)
                    : AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
