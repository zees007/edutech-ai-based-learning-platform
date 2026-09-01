import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final academicServiceProvider = Provider<AcademicService>((ref) {
  return AcademicService();
});

class AcademicService {
  final Dio _dio;

  AcademicService([Dio? dio])
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  /// Search across Semantic Scholar and OpenAlex in parallel, deduplicating results.
  Future<List<Map<String, dynamic>>> searchAll(
    String query, {
    int maxResults = 5,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final results = await Future.wait([
      searchSemanticScholar(cleanQuery, limit: maxResults).catchError((_) => <Map<String, dynamic>>[]),
      searchOpenAlex(cleanQuery, limit: maxResults).catchError((_) => <Map<String, dynamic>>[]),
    ]);

    final allPapers = <Map<String, dynamic>>[
      ...results[0],
      ...results[1],
    ];

    return _deduplicate(allPapers).take(maxResults).toList();
  }

  /// Search Semantic Scholar API (Free, includes AI TLDR summaries & Open Access PDFs).
  Future<List<Map<String, dynamic>>> searchSemanticScholar(
    String query, {
    int limit = 4,
  }) async {
    try {
      final sanitizedQuery = _sanitizeQuery(query);
      final response = await _dio.get(
        'https://api.semanticscholar.org/graph/v1/paper/search',
        queryParameters: {
          'query': sanitizedQuery,
          'limit': limit,
          'fields': 'title,authors,year,abstract,tldr,openAccessPdf,externalIds,url',
        },
      );

      final List data = response.data?['data'] ?? [];
      final List<Map<String, dynamic>> papers = [];

      for (final item in data) {
        if (item is! Map) continue;

        final rawAuthors = item['authors'];
        final List<String> authors = [];
        if (rawAuthors is List) {
          for (final a in rawAuthors.take(5)) {
            if (a is Map && a['name'] != null) {
              authors.add(a['name'].toString());
            }
          }
        }

        final tldrMap = item['tldr'];
        final String tldr = (tldrMap is Map ? tldrMap['text'] : null)?.toString() ?? '';
        final String abstractText = item['abstract']?.toString() ?? '';

        final oaPdf = item['openAccessPdf'];
        final String pdfUrl = (oaPdf is Map ? oaPdf['url'] : null)?.toString() ?? '';

        final extIds = item['externalIds'];
        final String doi = (extIds is Map ? extIds['DOI'] : null)?.toString() ?? '';

        final String paperId = item['paperId']?.toString() ?? '';
        final String directUrl = item['url']?.toString() ??
            (paperId.isNotEmpty ? 'https://www.semanticscholar.org/paper/$paperId' : '');

        papers.add({
          'title': item['title']?.toString() ?? 'Untitled Paper',
          'authors': authors.isNotEmpty ? authors : ['Unknown Authors'],
          'year': item['year']?.toString() ?? '2024',
          'abstract': abstractText,
          'tldr': tldr,
          'ai_summary': tldr.isNotEmpty ? tldr : abstractText,
          'pdf_url': pdfUrl,
          'doi': doi,
          'url': directUrl,
          'source': 'SEMANTIC SCHOLAR',
        });
      }

      return papers;
    } catch (_) {
      return [];
    }
  }

  /// Search OpenAlex Works API (Open-access scholarly repository).
  Future<List<Map<String, dynamic>>> searchOpenAlex(
    String query, {
    int limit = 4,
  }) async {
    try {
      final sanitizedQuery = _sanitizeQuery(query);
      final hasWildcard = sanitizedQuery.contains('*') || sanitizedQuery.contains('?');
      final searchKey = hasWildcard ? 'search.exact' : 'search';

      final response = await _dio.get(
        'https://api.openalex.org/works',
        queryParameters: {
          searchKey: sanitizedQuery,
          'per_page': limit,
          'sort': 'relevance_score:desc',
          'select': 'id,title,authorships,publication_year,doi,open_access,abstract_inverted_index',
        },
      );

      final List results = response.data?['results'] ?? [];
      final List<Map<String, dynamic>> papers = [];

      for (final work in results) {
        if (work is! Map) continue;

        // Reconstruct abstract from inverted index
        final String abstractText = _reconstructAbstract(work['abstract_inverted_index']);

        // Authors
        final rawAuthorships = work['authorships'];
        final List<String> authors = [];
        if (rawAuthorships is List) {
          for (final a in rawAuthorships.take(5)) {
            if (a is Map && a['author'] is Map && a['author']['display_name'] != null) {
              authors.add(a['author']['display_name'].toString());
            }
          }
        }

        // Open Access PDF
        final oa = work['open_access'];
        final String pdfUrl = (oa is Map ? oa['oa_url'] : null)?.toString() ?? '';
        final String doi = work['doi']?.toString() ?? '';
        final String openalexId = work['id']?.toString() ?? '';
        final String directUrl = doi.isNotEmpty ? doi : openalexId;

        papers.add({
          'title': work['title']?.toString() ?? 'Untitled Paper',
          'authors': authors.isNotEmpty ? authors : ['Unknown Authors'],
          'year': work['publication_year']?.toString() ?? '2024',
          'abstract': abstractText,
          'tldr': abstractText.isNotEmpty ? abstractText : '',
          'ai_summary': abstractText,
          'pdf_url': pdfUrl,
          'doi': doi,
          'url': directUrl,
          'source': 'OPENALEX',
        });
      }

      return papers;
    } catch (_) {
      return [];
    }
  }

  /// Reconstruct text from OpenAlex's abstract_inverted_index format.
  String _reconstructAbstract(dynamic invertedIndex) {
    if (invertedIndex is! Map) return '';

    final Map<int, String> positionToWord = {};
    invertedIndex.forEach((word, positions) {
      if (positions is List) {
        for (final pos in positions) {
          if (pos is int) {
            positionToWord[pos] = word.toString();
          }
        }
      }
    });

    if (positionToWord.isEmpty) return '';

    final sortedPositions = positionToWord.keys.toList()..sort();
    return sortedPositions.map((pos) => positionToWord[pos]!).join(' ');
  }

  /// Sanitize queries for external scholarly search APIs.
  String _sanitizeQuery(String query) {
    return query
        .replaceAll('?', ' ')
        .replaceAll('*', ' ')
        .replaceAll('"', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Deduplicate by normalized title similarity.
  List<Map<String, dynamic>> _deduplicate(List<Map<String, dynamic>> papers) {
    final Set<String> seenTitles = {};
    final List<Map<String, dynamic>> deduplicated = [];

    for (final paper in papers) {
      final title = (paper['title'] ?? '').toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (title.isNotEmpty && !seenTitles.contains(title)) {
        seenTitles.add(title);
        deduplicated.add(paper);
      }
    }

    return deduplicated;
  }
}
