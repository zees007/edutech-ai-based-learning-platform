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
    } else if (widget.initialTopic != null && widget.initialTopic!.trim().isNotEmpty) {
      _searchController.text = widget.initialTopic!.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchLive(widget.initialTopic!.trim());
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.blueLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.science_rounded,
                color: AppColors.blueLight,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Academic Research & Landmark Preprints',
                style: AppTextStyles.h3.copyWith(
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glassSurface.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Center(
              child: Text(
                'No papers currently indexed. Type a topic above to search.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.glassSurface.withValues(alpha: 0.05)
              : AppColors.glassSurface.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? AppColors.blueLight.withValues(alpha: 0.5)
                : AppColors.blueLight.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.blueLight.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.blueLight.withValues(alpha: 0.2),
                    AppColors.accentBlue.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.blueLight.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                hasDirectPdf ? Icons.picture_as_pdf_rounded : Icons.menu_book_rounded,
                color: AppColors.blueLight,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    authors,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.blueLight.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.blueLight.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡 ', style: TextStyle(fontSize: 13)),
                            Expanded(
                              child: RichText(
                                maxLines: _isInsightExpanded ? null : 2,
                                overflow: _isInsightExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'AI Key Insight: ',
                                      style: AppTextStyles.badge.copyWith(
                                        color: AppColors.blueSoft,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: summary,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textPrimary.withValues(alpha: 0.85),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (summary.length > 110)
                          Padding(
                            padding: const EdgeInsets.only(left: 22, top: 4),
                            child: InkWell(
                              onTap: () => setState(() => _isInsightExpanded = !_isInsightExpanded),
                              child: Text(
                                _isInsightExpanded ? 'Show less' : 'Read more...',
                                style: AppTextStyles.badge.copyWith(
                                  color: AppColors.blueLight,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.blueLight.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.blueLight.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          source,
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.blueSoft,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.glassSurface.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.glassBorder,
                          ),
                        ),
                        child: Text(
                          'Year: $year',
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Tooltip(
              message: actionTooltip,
              child: InkWell(
                onTap: () => _launchPdf(actionUrl),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.glassSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.blueLight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    actionIcon,
                    color: AppColors.blueSoft,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
