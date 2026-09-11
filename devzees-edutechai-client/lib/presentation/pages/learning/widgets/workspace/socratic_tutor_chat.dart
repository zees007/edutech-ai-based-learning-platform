import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/providers/active_session_provider.dart';
import 'mermaid_web_view.dart';

// ═══════════════════════════════════════════════════════════════════
// Socratic Tutor Chat — Premium Chat Bubble UI
//
// Renders the Socratic Tutor conversation as a modern chat interface:
// 1. tutorExplanation → first AI chat bubble (markdown-rendered)
// 2. Follow-up Q&A thread → alternating user/tutor bubbles
// 3. socraticQuestions[:2] → suggested follow-up question chips
// 4. Chat input bar → text field + gradient send button
// ═══════════════════════════════════════════════════════════════════

class SocraticTutorChat extends ConsumerStatefulWidget {
  final String? tutorExplanation;
  final List<dynamic>? socraticQuestions;
  final List<dynamic>? conversationHistory;
  final String stepTitle;
  final int? stepIndex;

  const SocraticTutorChat({
    super.key,
    this.tutorExplanation,
    this.socraticQuestions,
    this.conversationHistory,
    this.stepTitle = '',
    this.stepIndex,
  });

  @override
  ConsumerState<SocraticTutorChat> createState() => _SocraticTutorChatState();
}

class _SocraticTutorChatState extends ConsumerState<SocraticTutorChat>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isStreaming = false;
  final FocusNode _inputFocusNode = FocusNode();
  bool _isInputFocused = false;
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    _inputFocusNode.addListener(_onFocusChange);
    _initializeMessages();

    // Listen to websocket chunks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wsService = ref.read(learningWebSocketServiceProvider);
      _wsSubscription = wsService.events.listen(_onWebSocketEvent);
    });
  }

  void _onWebSocketEvent(Map<String, dynamic> event) {
    if (!mounted) return;

    // Performance fix: Ignore chunks when we're loading the full UI to avoid unnecessary
    // widget tree rebuilding behind the loading screen.
    if (ref.read(activeSessionProvider).isLoading) {
      return;
    }

    if (event['event_type'] == 'explanation_chunk') {
      final chunk = (event['content'] ?? event['chunk']) as String? ?? '';
      final isFinal = event['is_final'] as bool? ?? false;

      setState(() {
        if (_isStreaming &&
            _messages.isNotEmpty &&
            _messages.last.sender == _Sender.tutor) {
          // Append to existing streaming bubble
          _messages.last.text += chunk;
        } else if (chunk.isNotEmpty) {
          // First chunk received: turn off typing indicator and start streaming in the tutor bubble
          _isTyping = false;
          _isStreaming = true;
          final tutorAnim = _createAnimController();
          _messages.add(
            _ChatMessage(
              sender: _Sender.tutor,
              text: chunk,
              animController: tutorAnim,
            ),
          );
          tutorAnim.forward();
        }

        if (isFinal) {
          _isTyping = false;
          _isStreaming = false;
          if (_messages.isNotEmpty && _messages.last.sender == _Sender.tutor) {
            _messages.last.text = _sanitizeExplanation(_messages.last.text);
          }
        }
      });
      _scrollToBottom();
    } else if (event['event_type'] == 'error') {
      setState(() {
        _isTyping = false;
        _isStreaming = false;
        final errorAnim = _createAnimController();
        _messages.add(
          _ChatMessage(
            sender: _Sender.tutor,
            text: "⚠️ WebSocket Error: ${event['message']}",
            animController: errorAnim,
          ),
        );
        errorAnim.forward();
      });
      _scrollToBottom();
    }
  }

  void _onFocusChange() {
    if (_isInputFocused != _inputFocusNode.hasFocus) {
      setState(() {
        _isInputFocused = _inputFocusNode.hasFocus;
      });
    }
  }

  @override
  void didUpdateWidget(covariant SocraticTutorChat oldWidget) {
    super.didUpdateWidget(oldWidget);
    final historyChanged =
        oldWidget.conversationHistory != widget.conversationHistory &&
        (widget.conversationHistory?.length ?? 0) >
            (oldWidget.conversationHistory?.length ?? 0);
    if (oldWidget.stepTitle != widget.stepTitle ||
        oldWidget.tutorExplanation != widget.tutorExplanation ||
        oldWidget.stepIndex != widget.stepIndex ||
        (historyChanged && !_isStreaming && !_isTyping)) {
      for (final msg in _messages) {
        msg.animController.dispose();
      }
      _messages.clear();
      _controller.clear();
      _isTyping = false;
      _isStreaming = false;
      _initializeMessages();
      setState(() {});
    }
  }

  String _sanitizeExplanation(String text) {
    // Remove any trailing Socratic Questions section from the chat bubble
    final socraticPattern = RegExp(
      r'(?:\r?\n|\A)\s*(?:#{1,4}\s*)?\*{0,2}(?:socratic\s+questions?|guiding\s+questions?|suggested\s+questions?)\*{0,2}:?[\s\S]*$',
      caseSensitive: false,
    );
    final match = socraticPattern.firstMatch(text);
    if (match != null) {
      return text.substring(0, match.start).trim();
    }
    return text.trim();
  }

  void _initializeMessages() {
    // 1. Render tutorExplanation as the first tutor bubble (matching Streamlit)
    if (widget.tutorExplanation != null &&
        widget.tutorExplanation!.trim().isNotEmpty) {
      final sanitized = _sanitizeExplanation(widget.tutorExplanation!);
      _messages.add(
        _ChatMessage(
          sender: _Sender.tutor,
          text: sanitized,
          animController: _createAnimController(),
        ),
      );
    } else {
      // Fallback if explanation hasn't arrived yet
      _messages.add(
        _ChatMessage(
          sender: _Sender.tutor,
          text:
              '🧩 *Socratic Tutor Agent is preparing the explanation for **${widget.stepTitle}**...*',
          animController: _createAnimController(),
        ),
      );
    }

    // 2. Replay all follow-up conversation turns from conversationHistory
    if (widget.conversationHistory != null &&
        widget.conversationHistory!.isNotEmpty) {
      final initialSanitized = widget.tutorExplanation != null
          ? _sanitizeExplanation(widget.tutorExplanation!)
          : '';
      for (final rawTurn in widget.conversationHistory!) {
        if (rawTurn is! Map) continue;
        final turn = Map<String, dynamic>.from(rawTurn);
        final role = (turn['role'] as String? ?? '').toLowerCase();
        final content = (turn['content'] as String? ?? '').trim();
        if (content.isEmpty) continue;

        if (role == 'student' || role == 'user') {
          _messages.add(
            _ChatMessage(
              sender: _Sender.user,
              text: content,
              animController: _createAnimController(),
            ),
          );
        } else if (role == 'tutor' || role == 'assistant') {
          final sanitizedContent = _sanitizeExplanation(content);
          // Avoid duplicating the initial explanation if it was logged as a turn in conversation_history
          if (initialSanitized.isNotEmpty &&
              (sanitizedContent == initialSanitized ||
                  content == widget.tutorExplanation)) {
            continue;
          }
          _messages.add(
            _ChatMessage(
              sender: _Sender.tutor,
              text: sanitizedContent,
              animController: _createAnimController(),
            ),
          );
        }
      }
    }

    // Start entrance animations
    for (final msg in _messages) {
      msg.animController.forward();
    }
  }

  AnimationController _createAnimController() {
    return AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _sendMessage([String? prefilledText]) async {
    final text = prefilledText ?? _controller.text.trim();
    if (text.isEmpty) return;

    final userAnim = _createAnimController();
    setState(() {
      _messages.add(
        _ChatMessage(
          sender: _Sender.user,
          text: text,
          animController: userAnim,
        ),
      );
      _controller.clear();
      _isTyping = true;
      _isStreaming = false;
    });
    userAnim.forward();
    _scrollToBottom();

    final activeState = ref.read(activeSessionProvider);
    final sessionId = activeState.session?.sessionId;

    if (sessionId == null) {
      setState(() {
        _isTyping = false;
        _isStreaming = false;
      });
      return;
    }

    try {
      ref.read(activeSessionProvider.notifier).sendFollowUpChat(text);
    } catch (e) {
      if (!mounted) return;
      final errorAnim = _createAnimController();
      setState(() {
        _isTyping = false;
        _isStreaming = false;
        _messages.add(
          _ChatMessage(
            sender: _Sender.tutor,
            text:
                "⚠️ I encountered an issue connecting to the socratic agent. Please try asking again.",
            animController: errorAnim,
          ),
        );
      });
      errorAnim.forward();
      _scrollToBottom();
    }
  }

  List<String> get _suggestedQuestions {
    final fallbackQuestions = [
      'Can you explain this with a real-world analogy?',
      'Why is this step important for ${widget.stepTitle.isNotEmpty ? widget.stepTitle : "the topic"}?',
    ];

    final rawList = widget.socraticQuestions;
    if (rawList != null && rawList.isNotEmpty) {
      final parsed = rawList
          .map((q) {
            if (q is Map) return q['question']?.toString() ?? q.toString();
            return q.toString().trim();
          })
          .where((q) => q.isNotEmpty)
          .take(2)
          .toList();

      if (parsed.length >= 2) {
        return parsed;
      } else if (parsed.length == 1) {
        return [parsed.first, fallbackQuestions[1]];
      }
    }

    // Secondary recovery: if socraticQuestions wasn't provided separately,
    // extract them from tutorExplanation if present
    final extracted = _extractQuestionsFromText(widget.tutorExplanation);
    if (extracted.isNotEmpty) {
      if (extracted.length >= 2) return extracted.take(2).toList();
      return [extracted.first, fallbackQuestions[1]];
    }

    return fallbackQuestions;
  }

  List<String> _extractQuestionsFromText(String? text) {
    if (text == null || text.isEmpty) return [];
    final pattern = RegExp(
      r'(?:#{1,4}\s*)?\*{0,2}(?:socratic\s+questions?|guiding\s+questions?)\*{0,2}:?\s*([\s\S]*)',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);
    if (match == null) return [];

    final questionsBlock = match.group(1) ?? '';
    final lines = questionsBlock.split(RegExp(r'\r?\n'));
    final questions = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      final qMatch = RegExp(
        r'^(?:\d+[\.\)]|[-*•])\s+(.+)$',
      ).firstMatch(trimmed);
      if (qMatch != null) {
        final q = qMatch.group(1)?.trim() ?? '';
        if (q.isNotEmpty && !q.toLowerCase().startsWith('generate')) {
          questions.add(_cleanQuotes(q));
        }
      } else if (trimmed.endsWith('?') &&
          trimmed.length > 10 &&
          !trimmed.toLowerCase().startsWith('generate')) {
        questions.add(_cleanQuotes(trimmed));
      }
    }
    return questions;
  }

  String _cleanQuotes(String s) {
    var res = s.trim();
    if ((res.startsWith('"') && res.endsWith('"')) ||
        (res.startsWith("'") && res.endsWith("'"))) {
      if (res.length >= 2) {
        return res.substring(1, res.length - 1).trim();
      }
    }
    return res;
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _inputFocusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    for (final msg in _messages) {
      msg.animController.dispose();
    }
    super.dispose();
  }

  // ─── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildChatArea(),
        _buildSuggestedQuestions(),
        _buildInputBar(),
      ],
    );
  }

  // ─── Chat Area ─────────────────────────────────────────────────

  Widget _buildChatArea() {
    return ListView.builder(
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      shrinkWrap: true,
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        // Typing indicator at the end
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        final msg = _messages[index];
        return _buildChatBubble(msg);
      },
    );
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    final isTutor = msg.sender == _Sender.tutor;

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: msg.animController,
        curve: Curves.easeOut,
      ),
      child: SlideTransition(
        position:
            Tween<Offset>(
              begin: Offset(isTutor ? -0.15 : 0.15, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: msg.animController,
                curve: Curves.easeOutCubic,
              ),
            ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isTutor
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              if (isTutor) ...[_buildTutorAvatar(), const SizedBox(width: 10)],
              // Bubble
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: isTutor
                        ? LinearGradient(
                            colors: [
                              AppColors.surfaceMid.withValues(alpha: 0.75),
                              AppColors.surfaceDark.withValues(alpha: 0.85),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isTutor
                        ? null
                        : AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: isTutor
                        ? BorderRadius.circular(16)
                        : const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(4),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),

                    boxShadow: isTutor
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: const Color(
                                0xFF3B82F6,
                              ).withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: isTutor
                      ? _buildMarkdownContent(msg.text)
                      : _buildPlainText(msg.text),
                ),
              ),
              if (!isTutor) ...[
                const SizedBox(width: 10),
                // User avatar
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.accentBlue, AppColors.accentCyan],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentBlue.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🧑‍🎓', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Markdown Rendering (tutor bubbles) ────────────────────────

  Widget _buildMarkdownContent(String text) {
    final preprocessedText = _preprocessMathToMarkdown(text);

    return MarkdownBody(
      data: preprocessedText,
      selectable: true,
      onTapLink: (text, href, title) {
        if (href != null) launchUrl(Uri.parse(href));
      },
      styleSheet: _buildMarkdownStyleSheet(),
      builders: {'code': _CustomCodeBlockBuilder()},
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet() {
    final baseTextStyle = GoogleFonts.inter(
      color: Colors.white.withValues(alpha: 0.92),
      fontSize: 14,
      height: 1.55,
    );

    return MarkdownStyleSheet(
      // Body text
      p: baseTextStyle,
      pPadding: const EdgeInsets.only(bottom: 8),

      // Headers
      h1: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h1Padding: const EdgeInsets.only(bottom: 12, top: 4),
      h2: GoogleFonts.inter(
        color: AppColors.lavender,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h2Padding: const EdgeInsets.only(bottom: 10, top: 8),
      h3: GoogleFonts.inter(
        color: AppColors.primary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h3Padding: const EdgeInsets.only(bottom: 8, top: 6),

      // Bold & emphasis
      strong: GoogleFonts.inter(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      em: GoogleFonts.inter(
        color: Colors.white.withValues(alpha: 0.85),
        fontStyle: FontStyle.italic,
      ),

      // Links
      a: GoogleFonts.inter(
        color: AppColors.accentCyan,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.accentCyan.withValues(alpha: 0.4),
      ),

      // Lists
      listBullet: baseTextStyle.copyWith(color: AppColors.primary),
      listBulletPadding: const EdgeInsets.only(right: 8),
      listIndent: 20,

      // Inline code
      code: GoogleFonts.firaCode(
        color: AppColors.greenMint, // Vibrant green

        fontSize: 13,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
      ),

      // Code blocks
      codeblockDecoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      codeblockPadding: const EdgeInsets.all(14),

      // Blockquote
      blockquote: baseTextStyle.copyWith(
        color: Colors.white.withValues(alpha: 0.7),
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 14, top: 6, bottom: 6),

      // Table
      tableHead: GoogleFonts.inter(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      tableBody: GoogleFonts.inter(
        color: Colors.white.withValues(alpha: 0.85),
        fontSize: 13,
      ),
      tableBorder: TableBorder.all(
        color: Colors.white.withValues(alpha: 0.12),
        width: 1,
      ),
      tableHeadAlign: TextAlign.left,
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      // Horizontal rule
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
    );
  }

  Widget _buildPlainText(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: Colors.white.withValues(alpha: 0.92),
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  Widget _buildTutorAvatar() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromRGBO(14, 17, 23, 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPink.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: const Center(child: Text('🧩', style: TextStyle(fontSize: 14))),
    );
  }

  // ─── Typing Indicator ──────────────────────────────────────────

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTutorAvatar(),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceMid.withValues(alpha: 0.75),
                  AppColors.surfaceDark.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _TypingDots(),
          ),
        ],
      ),
    );
  }

  // ─── Suggested Questions ───────────────────────────────────────

  Widget _buildSuggestedQuestions() {
    final questions = _suggestedQuestions;
    if (questions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider line
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Label
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text('💡', style: GoogleFonts.inter(fontSize: 13)),
                const SizedBox(width: 6),
                Text(
                  'Suggested follow up questions',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Question chips
          ...questions.map(
            (q) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SuggestedQuestionChip(
                question: q,
                onTap: () => _sendMessage(q),
                disabled: _isTyping,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Input Bar ─────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _isInputFocused
              ? AppColors.surfaceDeep.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // AI sparkle badge icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.roseLight.withValues(alpha: 0.2),
                    AppColors.lavender.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.lavender,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            // Input TextField
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _inputFocusNode,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                cursorColor: AppColors.primary,
                maxLines: 1,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Ask Socratic Tutor a follow-up question...',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.38),
                    fontSize: 13.5,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
                enabled: !_isTyping,
              ),
            ),
            const SizedBox(width: 8),
            // Send Action Button
            _SendActionButton(isTyping: _isTyping, onTap: () => _sendMessage()),
          ],
        ),
      ),
    );
  }
}

class _SendActionButton extends StatefulWidget {
  final bool isTyping;
  final VoidCallback onTap;

  const _SendActionButton({required this.isTyping, required this.onTap});

  @override
  State<_SendActionButton> createState() => _SendActionButtonState();
}

class _SendActionButtonState extends State<_SendActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isTyping
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isTyping ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: widget.isTyping
                ? LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                  )
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isTyping
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: _isHovered ? 0.6 : 0.35,
                      ),
                      blurRadius: _isHovered ? 14 : 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isTyping
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  )
                : const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Typing Indicator — Animated Dots
// ═══════════════════════════════════════════════════════════════════

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final t = (_controller.value - delay).clamp(0.0, 1.0);
            final bounce = (t < 0.5) ? t * 2 : (1 - t) * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.translate(
                offset: Offset(0, -4 * bounce),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFFC084FC,
                    ).withValues(alpha: 0.4 + 0.5 * bounce),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Suggested Question Chip — Gradient Border Button
// ═══════════════════════════════════════════════════════════════════

class _SuggestedQuestionChip extends StatefulWidget {
  final String question;
  final VoidCallback onTap;
  final bool disabled;

  const _SuggestedQuestionChip({
    required this.question,
    required this.onTap,
    this.disabled = false,
  });

  @override
  State<_SuggestedQuestionChip> createState() => _SuggestedQuestionChipState();
}

class _SuggestedQuestionChipState extends State<_SuggestedQuestionChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final opacity = widget.disabled ? 0.4 : (_isHovered ? 1.0 : 0.75);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.disabled ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                AppColors.accentPink.withValues(
                  alpha: _isHovered ? 0.12 : 0.06,
                ),
                AppColors.primary.withValues(alpha: _isHovered ? 0.12 : 0.06),
                AppColors.accentBlue.withValues(
                  alpha: _isHovered ? 0.12 : 0.06,
                ),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppColors.primary.withValues(
                alpha: _isHovered ? 0.45 : 0.25,
              ),
              width: 1,
            ),
          ),
          child: Opacity(
            opacity: opacity,
            child: Row(
              children: [
                Text('💬', style: GoogleFonts.inter(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.question,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary.withValues(alpha: 0.5),
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Custom Code Block Builder — Intercepts mermaid and math blocks
// ═══════════════════════════════════════════════════════════════════

class _CustomCodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, preferredStyle) {
    final textContent = element.textContent;

    // 1. Inline Math
    if (textContent.startsWith('math:')) {
      final mathTex = textContent.substring(5).trim();
      return Math.tex(
        _sanitizeMathTex(mathTex),
        mathStyle: MathStyle.text,
        textStyle: preferredStyle?.copyWith(color: Colors.white, fontSize: 14),
        onErrorFallback: (err) => Text(
          mathTex,
          style: preferredStyle?.copyWith(color: AppColors.lavender),
        ),
      );
    }

    // 2. Block Math
    bool isLatexBlock =
        element.attributes['class']?.contains('language-latex') == true ||
        element.attributes['class']?.contains('language-math') == true;

    if (isLatexBlock) {
      return _buildMathCard(textContent);
    }

    // 3. Mermaid Diagrams (guaranteed untouched and prioritized for any mermaid code block)
    bool isMermaidBlock =
        element.attributes['class']?.contains('language-mermaid') == true;

    if (isMermaidBlock ||
        textContent.trimLeft().startsWith('graph ') ||
        textContent.trimLeft().startsWith('graph\n') ||
        textContent.trimLeft().startsWith('flowchart ') ||
        textContent.trimLeft().startsWith('sequenceDiagram') ||
        textContent.trimLeft().startsWith('classDiagram') ||
        textContent.trimLeft().startsWith('stateDiagram') ||
        textContent.trimLeft().startsWith('erDiagram') ||
        textContent.trimLeft().startsWith('gantt') ||
        textContent.trimLeft().startsWith('pie') ||
        textContent.trimLeft().startsWith('mindmap') ||
        ((textContent.contains('-->') || textContent.contains('---')) &&
            textContent.contains('['))) {
      return MermaidWebView(code: textContent);
    }

    return null;
  }
}

// ═══════════════════════════════════════════════════════════════════
// Chat Message Data Model
// ═══════════════════════════════════════════════════════════════════

enum _Sender { tutor, user }

class _ChatMessage {
  final _Sender sender;
  String text;
  final AnimationController animController;

  _ChatMessage({
    required this.sender,
    required this.text,
    required this.animController,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Math Rendering Utilities
// ═══════════════════════════════════════════════════════════════════

String _preprocessMathToMarkdown(String text) {
  // Protect all existing fenced code blocks (e.g. ```mermaid ... ``` or ```python ... ```)
  // so math preprocessing never touches diagram syntax or code samples.
  final codeBlocks = <String>[];
  var processed = text.replaceAllMapped(RegExp(r'```[\s\S]*?```'), (m) {
    codeBlocks.add(m.group(0)!);
    return '@@CODEBLOCK_${codeBlocks.length - 1}@@';
  });

  // 1. Block math: \begin{...} ... \end{...} with optional enclosing [ ... ] or \[ ... \]
  processed = processed.replaceAllMapped(
    RegExp(
      r'(?:\\\[|\[)?\s*(\\begin\{(?:aligned|matrix|bmatrix|pmatrix|vmatrix|cases|gather|equation)\b[\s\S]+?\\end\{(?:aligned|matrix|bmatrix|pmatrix|vmatrix|cases|gather|equation)\})\s*(?:\\\]|\])?',
      multiLine: true,
    ),
    (match) => '\n```latex\n${match.group(1)}\n```\n',
  );

  // 2. Block math: \[ ... \]
  processed = processed.replaceAllMapped(
    RegExp(r'\\\[([\s\S]+?)\\\]'),
    (match) => '\n```latex\n${match.group(1)}\n```\n',
  );

  // 3. Block math: $$ ... $$
  processed = processed.replaceAllMapped(
    RegExp(r'\$\$([\s\S]+?)\$\$'),
    (match) => '\n```latex\n${match.group(1)}\n```\n',
  );

  // 4. Inline math: \( ... \)
  processed = processed.replaceAllMapped(
    RegExp(r'\\\(([\s\S]+?)\\\)'),
    (match) => '`math:${match.group(1)}`',
  );

  // 5. Inline math with single $
  processed = processed.replaceAllMapped(
    RegExp(r'(?<!\$)\$(?!\$)([\s\S]+?)(?<!\$)\$(?!\$)'),
    (match) => '`math:${match.group(1)}`',
  );

  // 6. Common LLM fallback for inline math: ( \mathbf{...} ) or ( L=T-V ) etc., allowing following punctuation
  processed = processed.replaceAllMapped(
    RegExp(
      r'(?<!\S)\(\s*(\\[a-zA-Z]+[\s\S]*?|[a-zA-Z0-9_]+=[a-zA-Z0-9_+-]+)\s*\)(?=[,\.;:!?]|\s|$)',
    ),
    (match) => '`math:${match.group(1)}`',
  );

  // Restore protected code blocks untouched
  for (int i = 0; i < codeBlocks.length; i++) {
    processed = processed.replaceAll('@@CODEBLOCK_$i@@', codeBlocks[i]);
  }

  return processed;
}

String _sanitizeMathTex(String rawTex) {
  var clean = rawTex.trim();
  // 1. Remove unnecessary \! (negative thin space)
  clean = clean.replaceAll(r'\!', '');

  // 2. Replace comma followed by backslash(es) with LaTeX newline \\
  clean = clean.replaceAll(RegExp(r',\s*\\+'), r' \\ ');

  // 3. Replace comma followed by ampersand (multi-column equation separator) with \\
  clean = clean.replaceAll(RegExp(r',\s*&\s*'), r' \\ ');

  // 4. Normalize any sequence of 2+ backslashes with optional whitespace/backslashes (e.g. \\\ or \\ \ or \\\\) to \\
  clean = clean.replaceAll(RegExp(r'\\{2,}(?:\s*\\+)*'), r'\\');

  // 5. Remove any trailing \\ or \ right before \end{...}
  clean = clean.replaceAll(RegExp(r'\\+\s*(?=\\end\{)'), '\n');

  // 6. Remove any stray trailing backslash before newline or end of string
  clean = clean.replaceAll(RegExp(r'(?<!\\)\\\s*(?=\r?\n|$)'), '');

  return clean.trim();
}

Widget _buildMathCard(String tex) {
  final cleanTex = _sanitizeMathTex(tex);
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.surfaceDark.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(12),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Math.tex(
        cleanTex,
        mathStyle: MathStyle.display,
        textStyle: const TextStyle(color: Colors.white, fontSize: 15),
        onErrorFallback: (err) => Text(
          cleanTex,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontFamily: 'monospace',
            fontSize: 13,
          ),
        ),
      ),
    ),
  );
}
