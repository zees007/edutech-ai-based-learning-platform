import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/services/feedback_service.dart';

/// Modal dialog shown upon completing all milestones.
/// Prompts the student to submit a 1-5 star rating and short review (max 250 chars)
/// in exchange for a +30 XP bonus before showing the Journey Complete Celebration.
class SessionFeedbackDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final String topic;
  final Function(int bonusXpAwarded) onCompleted;
  final VoidCallback onSkipped;

  const SessionFeedbackDialog({
    super.key,
    required this.sessionId,
    required this.topic,
    required this.onCompleted,
    required this.onSkipped,
  });

  @override
  ConsumerState<SessionFeedbackDialog> createState() =>
      _SessionFeedbackDialogState();
}

class _SessionFeedbackDialogState extends ConsumerState<SessionFeedbackDialog> {
  int _rating = 5;
  final TextEditingController _quoteController = TextEditingController();
  bool _isPublicConsent = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _quoteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final quoteText = _quoteController.text.trim();
    if (quoteText.length < 5) {
      setState(() {
        _errorMessage = 'Please write at least a few words (min 5 characters).';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final feedbackService = ref.read(feedbackServiceProvider);
      final response = await feedbackService.submitFeedback(
        sessionId: widget.sessionId,
        rating: _rating,
        quote: quoteText,
        isPublicConsent: _isPublicConsent,
      );

      if (!mounted) return;
      widget.onCompleted(response.xpAwarded);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xE60F111E)
                      : const Color(0xF5FFFFFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? const Color(0x33F59E0B)
                        : const Color(0x22F59E0B),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      blurRadius: 36,
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Row: Topic Badge & XP Callout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  const Color(0xFFF59E0B).withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                size: 14,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '+30 XP BONUS',
                                style: AppTextStyles.badge.copyWith(
                                  color: const Color(0xFFFDE68A),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                          onPressed: _isSubmitting ? null : widget.onSkipped,
                          tooltip: 'Skip',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Header Title
                    Text(
                      'Rate Your Masterclass',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'How was your learning experience on "${widget.topic}"? Share quick feedback to claim your bonus XP.',
                      style: AppTextStyles.body2.copyWith(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Interactive Star Rating
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          final isSelected = starIndex <= _rating;
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: _isSubmitting
                                  ? null
                                  : () => setState(() => _rating = starIndex),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: AnimatedScale(
                                  scale: isSelected ? 1.15 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 38,
                                    color: isSelected
                                        ? const Color(0xFFFBBF24)
                                        : (isDark
                                            ? Colors.white12
                                            : Colors.black12),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Testimonial Quote Field (Max 250 characters)
                    TextField(
                      controller: _quoteController,
                      maxLength: 250,
                      maxLines: 3,
                      enabled: !_isSubmitting,
                      style: AppTextStyles.body2.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'What was most helpful? (e.g. Socratic hints, video clips, derivations...)',
                        hintStyle: AppTextStyles.body2.copyWith(
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                        ),
                        counterStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFF64748B)
                              : const Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0x331E293B)
                            : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFF59E0B),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    // Public Consent Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _isPublicConsent,
                          activeColor: const Color(0xFFF59E0B),
                          onChanged: _isSubmitting
                              ? null
                              : (val) {
                                  setState(() => _isPublicConsent = val ?? true);
                                },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isSubmitting
                                ? null
                                : () {
                                    setState(
                                        () => _isPublicConsent = !_isPublicConsent);
                                  },
                            child: Text(
                              'Feature my review on the homepage Wall of Love',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF475569),
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Primary Action: Submit & Claim +30 XP
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFF59E0B).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.celebration_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Submit & Claim +30 XP',
                                    style: AppTextStyles.button.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Secondary Action: Skip for now
                    Center(
                      child: TextButton(
                        onPressed: _isSubmitting ? null : widget.onSkipped,
                        child: Text(
                          'Skip for now',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

