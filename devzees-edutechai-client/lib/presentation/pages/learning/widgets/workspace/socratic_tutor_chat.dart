import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/app_colors.dart';

class SocraticTutorChat extends StatefulWidget {
  final List<dynamic>? socraticQuestions;

  const SocraticTutorChat({super.key, this.socraticQuestions});

  @override
  State<SocraticTutorChat> createState() => _SocraticTutorChatState();
}

class _SocraticTutorChatState extends State<SocraticTutorChat> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    if (widget.socraticQuestions != null && widget.socraticQuestions!.isNotEmpty) {
      final initialQuestion = widget.socraticQuestions!.first;
      String qText = initialQuestion is Map ? initialQuestion['question'] ?? 'What do you think about this topic?' : initialQuestion.toString();
      _messages.add({'sender': 'tutor', 'text': qText});
    } else {
      _messages.add({'sender': 'tutor', 'text': 'How can I help you understand this topic better?'});
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': _controller.text.trim()});
      _controller.clear();
      // Simulate tutor typing
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.add({'sender': 'tutor', 'text': 'That\'s an interesting perspective. Why do you think that happens?'});
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentPink.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.accentPink, AppColors.primary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPink.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(child: Text('🧩', style: TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Socratic Tutor',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Online',
                      style: GoogleFonts.inter(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Chat Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isTutor = msg['sender'] == 'tutor';
                return Align(
                  alignment: isTutor ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    decoration: BoxDecoration(
                      color: isTutor ? const Color(0xFFC084FC).withOpacity(0.15) : AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomLeft: isTutor ? const Radius.circular(0) : const Radius.circular(16),
                        bottomRight: !isTutor ? const Radius.circular(0) : const Radius.circular(16),
                      ),
                      border: Border.all(
                        color: isTutor ? const Color(0xFFC084FC).withOpacity(0.3) : AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      msg['text']!,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.inter(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Answer or ask a question...',
                        hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.4)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _sendMessage,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accentBlue, AppColors.primary],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
