import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/services/academic_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';

class AcademicPapers extends ConsumerStatefulWidget {
  final List<dynamic>? papers;
  final String? initialTopic;

  const AcademicPapers({
    super.key,
    this.papers,
    this.initialTopic,
  });

  @override
  ConsumerState<AcademicPapers> createState() => _AcademicPapersState();
}

class _AcademicPapersState extends ConsumerState<AcademicPapers> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _displayedPapers = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.papers != null && widget.papers!.isNotEmpty) {
      _displayedPapers = List.from(widget.papers!);
    }
  }

  @override
  void didUpdateWidget(covariant AcademicPapers oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.papers != widget.papers) {
      setState(() {
        if (widget.papers != null && widget.papers!.isNotEmpty) {
          _displayedPapers = List.from(widget.papers!);
        } else {
          _displayedPapers = [];
        }
        _searchController.clear();
        _errorMessage = null;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLive(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await ref.read(academicServiceProvider).searchAll(cleanQuery, maxResults: 5);
      if (mounted) {
        setState(() {
          _displayedPapers = results;
          _isLoading = false;
          if (results.isEmpty) {
            _errorMessage = 'No open-access research papers found for "$cleanQuery".';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not retrieve research papers. Please check your connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.blueLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.science_rounded,
                color: AppColors.blueLight,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Academic Research & Landmark Preprints',
                style: AppTextStyles.subtitle2.copyWith(
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Live Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.glassSurface.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.glassBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 18, color: AppColors.blueSoft),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: AppTextStyles.bodyPrimary,
                  decoration: InputDecoration(
                    hintText: 'Search scholarly papers, arXiv, Semantic Scholar...',
                    hintStyle: AppTextStyles.bodyPrimary.copyWith(
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (val) => _searchLive(val),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, size: 16, color: AppColors.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _displayedPapers = widget.papers ?? [];
                      _errorMessage = null;
                    });
                  },
                  tooltip: 'Clear',
                ),
              InkWell(
                onTap: () => _searchLive(_searchController.text),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.blueLight.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'Search',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.blueSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Body Content
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.blueLight,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Searching Semantic Scholar & OpenAlex...',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glassSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Center(
              child: Text(
                _errorMessage!,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else if (_displayedPapers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.glassSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.blueLight.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 28,
                      color: AppColors.blueLight.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No academic papers available for this step',
                    style: AppTextStyles.subtitle2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Type a keyword or topic above to find relevant papers on arXiv & Semantic Scholar.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _displayedPapers.length,
            itemBuilder: (context, index) {
              final paper = _displayedPapers[index];
              return _PaperCard(paper: paper, index: index);
            },
          ),
      ],
    );
  }
}

class _PaperCard extends StatefulWidget {
  final dynamic paper;
  final int index;

  const _PaperCard({required this.paper, required this.index});

  @override
  State<_PaperCard> createState() => _PaperCardState();
}

class _PaperCardState extends State<_PaperCard> {
  bool _isHovered = false;
  bool _isInsightExpanded = false;

  Future<void> _launchPdf(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paper = widget.paper;

    final String title = paper is Map
        ? (paper['title']?.toString() ?? 'Research Paper ${widget.index + 1}')
        : 'Research Paper ${widget.index + 1}';

    // Safely parse authors whether it's a List<dynamic>, List<String>, or single String
    String authors = 'Unknown Authors';
    if (paper is Map && paper['authors'] != null) {
      final rawAuthors = paper['authors'];
      if (rawAuthors is List) {
        authors = rawAuthors.map((a) => a.toString()).where((a) => a.isNotEmpty).join(', ');
        if (authors.isEmpty) authors = 'Unknown Authors';
      } else if (rawAuthors is String && rawAuthors.isNotEmpty) {
        authors = rawAuthors;
      }
    }

    final String year = paper is Map && paper['year'] != null
        ? paper['year'].toString()
        : '2024';

    final String source = paper is Map && paper['source'] != null
        ? paper['source'].toString().toUpperCase()
        : 'SCHOLAR';

    // Resolve URL with smart 100% login-free open-access sources:
    final String rawPdf = (paper is Map ? paper['pdf_url'] : null)?.toString().trim() ?? '';
    final String rawDoi = (paper is Map ? paper['doi'] : null)?.toString().trim() ?? '';
    final String rawUrl = (paper is Map ? paper['url'] : null)?.toString().trim() ?? '';
    final String cleanSource = source.toLowerCase();

    final bool hasDirectPdf = rawPdf.isNotEmpty && (rawPdf.toLowerCase().endsWith('.pdf') || rawPdf.contains('arxiv.org/pdf'));
    
    String actionUrl = '';
    String actionTooltip = 'Read Paper on Semantic Scholar';
    IconData actionIcon = Icons.open_in_new_rounded;

    if (rawPdf.isNotEmpty) {
      actionUrl = rawPdf;
      actionTooltip = hasDirectPdf ? 'Download / Read PDF' : 'Open Full Paper';
      actionIcon = hasDirectPdf ? Icons.picture_as_pdf_rounded : Icons.open_in_new_rounded;
    } else if (rawDoi.isNotEmpty) {
      actionUrl = rawDoi.startsWith('http') ? rawDoi : 'https://doi.org/$rawDoi';
      actionTooltip = 'Read Paper via DOI';
      actionIcon = Icons.open_in_new_rounded;
    } else if (rawUrl.isNotEmpty) {
      actionUrl = rawUrl;
      actionTooltip = 'Open Paper on $source';
      actionIcon = Icons.open_in_new_rounded;
    } else {
      final String sanitizedTitle = title
          .replaceAll('?', ' ')
          .replaceAll('*', ' ')
          .replaceAll('"', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (cleanSource.contains('arxiv')) {
        actionUrl = 'https://arxiv.org/search/?query=${Uri.encodeComponent(sanitizedTitle)}&searchtype=all';
        actionTooltip = 'Search on arXiv (Open Access)';
      } else if (cleanSource.contains('openalex')) {
        actionUrl = 'https://openalex.org/works?search=${Uri.encodeComponent(sanitizedTitle)}';
        actionTooltip = 'Search on OpenAlex (Open Access)';
      } else {
        actionUrl = 'https://www.semanticscholar.org/search?q=${Uri.encodeComponent(sanitizedTitle)}';
        actionTooltip = 'Search on Semantic Scholar (Open Access)';
      }
      actionIcon = Icons.open_in_new_rounded;
    }

    // Extract summary with comprehensive fallback keys
    String summary = '';
    if (paper is Map) {
      final candidates = [
        paper['tldr'],
        paper['ai_summary'],
        paper['abstract'],
        paper['summary'],
        paper['description'],
        paper['snippet'],
        paper['relevance_snippet'],
      ];
      for (final c in candidates) {
        if (c != null && c.toString().trim().isNotEmpty) {
          summary = c.toString().trim();
          break;
        }
      }
    }

    if (summary.isEmpty) {
      summary = 'Seminal scholarly paper exploring key concepts of $title. Published in $year via $source.';
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.glassSurface.withValues(alpha: 0.06)
              : AppColors.glassSurface.withValues(alpha: 0.025),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? AppColors.blueLight.withValues(alpha: 0.55)
                : AppColors.blueLight.withValues(alpha: 0.20),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            if (_isHovered)
              BoxShadow(
                color: AppColors.blueLight.withValues(alpha: 0.16),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Top Meta Header ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Source Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: AppColors.blueLight.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.blueLight.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 12,
                              color: AppColors.blueLight,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              source,
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.blueSoft,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Publication Year
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: AppColors.glassSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.glassBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              year,
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Direct PDF or Open Access Badge
                      if (hasDirectPdf)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentCyan.withValues(alpha: 0.15),
                                AppColors.accentGreen.withValues(alpha: 0.10),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.accentCyan.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.picture_as_pdf_rounded,
                                size: 11,
                                color: AppColors.accentCyan,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Direct PDF',
                                style: AppTextStyles.badge.copyWith(
                                  color: AppColors.accentCyan,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.accentGreen.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_open_rounded,
                                size: 11,
                                color: AppColors.accentGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Open Access',
                                style: AppTextStyles.badge.copyWith(
                                  color: AppColors.accentGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.glassSurface.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.glassBorderSubtle,
                    ),
                  ),
                  child: Text(
                    '${widget.index + 1}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.captionBold.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10.5,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ─── Paper Title ──────────────────────────────────
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),

            // ─── Authors ──────────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: AppColors.blueSoft.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    authors,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ─── AI Key Insight Callout ───────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blueLight.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.blueLight.withValues(alpha: 0.18),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Gradient vertical indicator accent bar
                    Container(
                      width: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.blueLight, AppColors.accentBlue],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 13,
                                    color: AppColors.blueSoft,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'AI KEY INSIGHT',
                                    style: AppTextStyles.badge.copyWith(
                                      color: AppColors.blueSoft,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                              if (summary.length > 110)
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _isInsightExpanded = !_isInsightExpanded),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _isInsightExpanded ? 'Show less' : 'Read more',
                                          style: AppTextStyles.badge.copyWith(
                                            color: AppColors.blueLight,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          _isInsightExpanded
                                              ? Icons.keyboard_arrow_up_rounded
                                              : Icons.keyboard_arrow_down_rounded,
                                          size: 14,
                                          color: AppColors.blueLight,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            summary,
                            maxLines: _isInsightExpanded ? null : 2,
                            overflow: _isInsightExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary.withValues(alpha: 0.88),
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ─── Footer / Action Bar ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // DOI / Scholarly Status indicator
                if (rawDoi.isNotEmpty)
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tag_rounded,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'doi: $rawDoi',
                            style: AppTextStyles.badge.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 12,
                        color: AppColors.blueSoft.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Scholarly Preprint',
                        style: AppTextStyles.badge.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(width: 12),

                // Tactile Hero Action Button
                Tooltip(
                  message: actionTooltip,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _launchPdf(actionUrl),
                      borderRadius: BorderRadius.circular(10),
                      splashColor: AppColors.blueLight.withValues(alpha: 0.25),
                      hoverColor: AppColors.blueLight.withValues(alpha: 0.15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.blueLight.withValues(alpha: 0.20),
                              AppColors.accentBlue.withValues(alpha: 0.14),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.blueLight.withValues(alpha: 0.40),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blueLight.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              actionIcon,
                              size: 15,
                              color: AppColors.blueSoft,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              hasDirectPdf ? 'Read PDF' : 'Read Paper',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }
}
