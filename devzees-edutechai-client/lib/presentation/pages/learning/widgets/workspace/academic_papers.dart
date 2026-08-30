import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/app_colors.dart';

class AcademicPapers extends StatelessWidget {
  final List<dynamic>? papers;

  const AcademicPapers({super.key, this.papers});

  @override
  Widget build(BuildContext context) {
    if (papers == null || papers!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('📚', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              'Research Papers & Preprints',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: papers!.length,
          itemBuilder: (context, index) {
            final paper = papers![index];
            final title = paper is Map ? paper['title'] ?? 'Research Paper ${index + 1}' : 'Research Paper ${index + 1}';
            final authors = paper is Map ? paper['authors'] ?? 'Unknown Authors' : 'Unknown Authors';
            final year = paper is Map ? paper['year'] ?? '2023' : '2023';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF60A5FA).withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF60A5FA).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF60A5FA), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authors,
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Published: $year',
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: Colors.white54),
                    onPressed: () {},
                    tooltip: 'Download PDF',
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
