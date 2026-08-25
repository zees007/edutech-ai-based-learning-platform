import 'package:flutter/material.dart';
import 'package:devzees_edutechai_client/presentation/widgets/glow_background.dart';
import 'package:devzees_edutechai_client/core/constants/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_text.dart';
import 'package:devzees_edutechai_client/core/theme/app_colors.dart';
import 'package:devzees_edutechai_client/presentation/widgets/gradient_button.dart';
import 'package:devzees_edutechai_client/presentation/widgets/journey_prompt_card.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  bool isExpanded = true;
  bool _isHistoryExpanded = true;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white70),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: AppColors.background,
          child: _buildSidebarContent(expanded: true, isMobile: true),
        ),
        body: GlowBackground(child: _buildMainContent(isMobile)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GlowBackground(
        child: Row(
          children: [
            // Sidebar
            Container(
              width: isExpanded ? 280 : 80,
              decoration: BoxDecoration(
                color: const Color(0xFF130D21),
                border: Border(
                  right: BorderSide(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
              child: _buildSidebarContent(
                expanded: isExpanded,
                isMobile: false,
              ),
            ),

            // Main Content
            Expanded(child: _buildMainContent(isMobile)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : 32.0,
                    vertical: isMobile ? 24.0 : 48.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'EduTechAI ',
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          GradientText(
                            'Learning Workspace',
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'An adaptive, intelligent learning studio where specialized AI agents orchestrate personalized roadmaps, intuitive analogies, video deep-dives, and instant mastery checks.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 14 : 16,
                          color: Colors.white.withValues(alpha: 0.7),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 24.0 : 48.0),
                  child: const Center(
                    child: Text(
                      'Workspace Content\n(To be implemented)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Pinned Bottom Section
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16.0 : 32.0,
            vertical: isMobile ? 8.0 : 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    'What do you want to ',
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GradientText(
                    'learn today?',
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                'Decompose any concept into adaptive milestones, interactive Socratic lessons, and academic research.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 13 : 15,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: isMobile ? 8 : 16),
              JourneyPromptCard(
                onStartJourney: () {
                  // TODO: Handle start journey
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarContent({
    required bool expanded,
    required bool isMobile,
  }) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(expanded: expanded, isMobile: isMobile),
          const SizedBox(height: 16),
          _buildNewJourneyButton(expanded: expanded),
          const SizedBox(height: 24),
          if (expanded) ...[
            _buildHistoryHeader(),
            if (_isHistoryExpanded) ...[
              const SizedBox(height: 16),
              _buildSearchAndFilter(),
              const SizedBox(height: 16),
            ],
          ],
          // History List
          if (expanded && !_isHistoryExpanded)
            const Spacer()
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: 15,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(index, expanded: expanded);
                },
              ),
            ),
          _buildFooter(expanded: expanded),
        ],
      ),
    );
  }

  Widget _buildHeader({required bool expanded, required bool isMobile}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: expanded
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          if (expanded)
            Row(
              children: [
                Text(
                  '⚡ ',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                GradientText(
                  'EduTech',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'AI',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFC084FC),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          if (!isMobile)
            IconButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              icon: Icon(
                expanded ? Icons.menu_open : Icons.menu,
                color: Colors.white70,
              ),
            )
          else
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.menu_open, color: Colors.white70),
            ),
        ],
      ),
    );
  }

  Widget _buildNewJourneyButton({required bool expanded}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: expanded
          ? GradientButton(
              text: 'Start New Journey',
              icon: Icons.edit_square,
              iconFirst: true,
              onPressed: () {},
              height: 48,
            )
          : InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_square, color: Colors.white),
              ),
            ),
    );
  }

  Widget _buildHistoryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            _isHistoryExpanded = !_isHistoryExpanded;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            children: [
              const Text(
                'Learning History',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Icon(
                _isHistoryExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                color: Colors.white.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.filter_list,
                color: Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(int index, {required bool expanded}) {
    if (!expanded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${index + 1}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: Colors.white.withValues(alpha: 0.4),
                size: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Learning Session ${index + 1}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter({required bool expanded}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: expanded
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFA855F7).withValues(alpha: 0.2),
            child: const Text(
              'Z',
              style: TextStyle(
                color: Color(0xFFA855F7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (expanded) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Zeeshan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Free Plan',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white54, size: 20),
              onPressed: () {},
            ),
          ],
        ],
      ),
    );
  }
}
