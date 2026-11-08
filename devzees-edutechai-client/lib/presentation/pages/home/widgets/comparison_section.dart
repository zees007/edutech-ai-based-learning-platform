import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/core/theme/text_styles.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';

enum _ComparisonViewMode { table, cards }

class ComparisonSection extends StatefulWidget {
  const ComparisonSection({super.key});

  @override
  State<ComparisonSection> createState() => _ComparisonSectionState();
}

class _ComparisonSectionState extends State<ComparisonSection> {
  _ComparisonViewMode _viewMode = _ComparisonViewMode.table;
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isCompact = screenWidth < 880;
    final double tableWidth = (screenWidth - 48).clamp(720.0, 1200.0);

    const comparisonItems = [
      _ComparisonItem(
        icon: Icons.psychology_alt_rounded,
        dimension: 'How You Learn',
        generic:
            'Dumps overwhelming walls of text that are easy to skim and quickly forget.',
        genericTag: 'Passive Reading',
        edutech:
            'Interactive step-by-step guidance with relatable analogies and smart hints so you discover answers yourself.',
        edutechTag: 'Active Guidance',
        advantageBadge: 'Better Retention',
      ),
      _ComparisonItem(
        icon: Icons.alt_route_rounded,
        dimension: 'Learning Roadmap',
        generic:
            'Answers questions one by one with no clear learning path, milestones, or progression.',
        genericTag: 'No Clear Path',
        edutech:
            'Creates a personalized 4–7 step roadmap for any topic, identifying what you need to learn first so you never get stuck.',
        edutechTag: 'Step-by-Step Path',
        advantageBadge: 'Step Mastery',
      ),
      _ComparisonItem(
        icon: Icons.video_collection_rounded,
        dimension: 'Curated Video Lessons',
        generic:
            'Links to full-length 30–60 minute videos, leaving you to manually scrub through the timeline to find the relevant explanation.',
        genericTag: 'Full-Length Videos',
        edutech:
            'Embeds curated video lessons pre-cued to the exact minute and second explaining your concept—zero scrubbing needed.',
        edutechTag: 'Pre-Cued to Key Moments',
        advantageBadge: 'Zero Scrubbing',
      ),
      _ComparisonItem(
        icon: Icons.auto_stories_rounded,
        dimension: 'Real Research & Sources',
        generic:
            'Pulls general web articles and blog summaries, often linking to studies locked behind publisher paywalls.',
        genericTag: 'Paywalls & Blog Posts',
        edutech:
            'Searches 250M+ scholarly papers across arXiv, OpenAlex, and Semantic Scholar with direct, free open-access PDF links.',
        edutechTag: 'Direct Open-Access PDFs',
        advantageBadge: 'Free Full Papers',
      ),
      _ComparisonItem(
        icon: Icons.fact_check_rounded,
        dimension: 'Quizzes & Progress',
        generic:
            'Never checks if you actually understood the concept before moving on.',
        genericTag: 'No Understanding Check',
        edutech:
            'Quick interactive quizzes after every lesson with XP rewards and streak tracking to keep you motivated.',
        edutechTag: 'Interactive Quizzes',
        advantageBadge: 'XP & Daily Streaks',
      ),
      _ComparisonItem(
        icon: Icons.folder_zip_rounded,
        dimension: 'Saving & Exporting Notes',
        generic:
            'Requires messy copy-pasting that ruins formatting, diagrams, and math formulas.',
        genericTag: 'Messy Copy-Paste',
        edutech:
            'Export your entire study roadmap to Notion, Obsidian, or clean PDF in one click—diagrams and formulas included.',
        edutechTag: 'Notion, Obsidian & PDF',
        advantageBadge: '1-Click Export',
      ),
    ];

    return Column(
      children: [
        // Section Header Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEC4899).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: const Color(0xFFEC4899).withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEC4899).withValues(alpha: 0.18),
                blurRadius: 18,
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEC4899),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFEC4899),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'WHY EDUTECH AI',
                  style: TextStyle(
                    color: Color(0xFFFBCFE8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        GradientText(
          'Beyond Generic AI Chatbots',
          style: (isMobile ? AppTextStyles.h3 : AppTextStyles.h2).copyWith(
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Text(
            'Generic AI chatbots give quick answers and move on. EduTech AI acts like an expert 1-on-1 personal tutor—guiding you step-by-step until you truly master any topic.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: const Color(0xFF94A3B8),
              fontSize: isMobile ? 15 : 17,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // ─── Compact / Mobile View Switcher (Table View vs Feature Cards) ───
        if (isCompact) ...[
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xEE090A14),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildViewToggle(
                    isSelected: _viewMode == _ComparisonViewMode.table,
                    icon: Icons.table_chart_rounded,
                    label: 'Table View',
                    onTap: () =>
                        setState(() => _viewMode = _ComparisonViewMode.table),
                  ),
                  const SizedBox(width: 4),
                  _buildViewToggle(
                    isSelected: _viewMode == _ComparisonViewMode.cards,
                    icon: Icons.view_agenda_rounded,
                    label: 'Feature Cards',
                    onTap: () =>
                        setState(() => _viewMode = _ComparisonViewMode.cards),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // ─── Content Render: Table Matrix or Dimension Cards ───
        if (isCompact && _viewMode == _ComparisonViewMode.cards)
          Column(
            children: comparisonItems
                .map((item) => _buildMobileComparisonCard(item))
                .toList(),
          )
        else
          _buildTable(
            items: comparisonItems,
            tableWidth: tableWidth,
            isCompact: isCompact,
            isMobile: isMobile,
          ),
      ],
    );
  }

  Widget _buildViewToggle({
    required bool isSelected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6).withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6).withValues(alpha: 0.6)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollHint(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.20),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.swap_horiz_rounded,
              size: 16,
              color: Color(0xFF60A5FA),
            ),
            const SizedBox(width: 8),
            Text(
              isMobile
                  ? 'Swipe horizontally to compare columns'
                  : 'Scroll horizontally to view complete matrix',
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable({
    required List<_ComparisonItem> items,
    required double tableWidth,
    required bool isCompact,
    required bool isMobile,
  }) {
    final tableBox = Container(
      decoration: BoxDecoration(
        color: const Color(0xDD0A0D1D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
            blurRadius: 32,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F132A),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Center(
                      child: Text(
                        'LEARNING FEATURE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Generic Chatbots',
                                style: TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                            ),
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withValues(alpha: 0.35),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.hub_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'EduTech AI Personal Tutor',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Table Rows
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: index.isEven
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.015),
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dimension Column
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                item.icon,
                                size: 17,
                                color: const Color(0xFF60A5FA),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.dimension,
                                style: const TextStyle(
                                  color: Color(0xFFF1F5F9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Generic Chatbot Column
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFEF4444,
                                ).withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 13,
                                color: Color(0xFFF87171),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.generic,
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // EduTech AI Column
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF3B82F6,
                          ).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFF3B82F6,
                            ).withValues(alpha: 0.22),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.35),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Color(0xFF34D399),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.edutech,
                                    style: const TextStyle(
                                      color: Color(0xFFF8FAFC),
                                      fontSize: 13,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF00F5D4,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF00F5D4,
                                        ).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      item.advantageBadge,
                                      style: const TextStyle(
                                        color: Color(0xFF00F5D4),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );

    if (isCompact) {
      return Column(
        children: [
          _buildScrollHint(isMobile),
          const SizedBox(height: 14),
          SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(width: tableWidth, child: tableBox),
          ),
        ],
      );
    }

    return tableBox;
  }

  Widget _buildMobileComparisonCard(_ComparisonItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xDD0A0D1D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Icon, Dimension, and Advantage Badge
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  item.icon,
                  size: 18,
                  color: const Color(0xFF60A5FA),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.dimension,
                  style: const TextStyle(
                    color: Color(0xFFF1F5F9),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00F5D4).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF00F5D4).withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  item.advantageBadge,
                  style: const TextStyle(
                    color: Color(0xFF00F5D4),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. EduTech AI Multi-Agent Squad (Winner)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'EduTech AI Tutor',
                        style: TextStyle(
                          color: Color(0xFF60A5FA),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.edutechTag,
                        style: const TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.edutech,
                  style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 12.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 2. Generic AI Chatbots (ChatGPT)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.025),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: Color(0xFFF87171),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Generic Chatbots',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.genericTag,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.generic,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonItem {
  final IconData icon;
  final String dimension;
  final String generic;
  final String genericTag;
  final String edutech;
  final String edutechTag;
  final String advantageBadge;

  const _ComparisonItem({
    required this.icon,
    required this.dimension,
    required this.generic,
    required this.genericTag,
    required this.edutech,
    required this.edutechTag,
    required this.advantageBadge,
  });
}
