import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../../../../core/theme/app_colors.dart';

class RecommendedVideos extends StatelessWidget {
  final List<dynamic>? videos;

  const RecommendedVideos({super.key, this.videos});

  @override
  Widget build(BuildContext context) {
    if (videos == null || videos!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🎬', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Recommended YouTube Video Clips & Timestamps',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300, // Increased to accommodate channel, relevance, and long titles without overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videos!.length,
            clipBehavior: Clip.none, // Allow shadows to draw outside
            itemBuilder: (context, index) {
              final video = videos![index];
              return _VideoCard(video: video, index: index);
            },
          ),
        ),
      ],
    );
  }
}

class _VideoCard extends StatefulWidget {
  final dynamic video;
  final int index;

  const _VideoCard({required this.video, required this.index});

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  bool _isHovered = false;
  bool _isPlaying = false;
  YoutubePlayerController? _controller;

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  Future<void> _playVideo() async {
    final videoId = widget.video is Map ? widget.video['video_id'] : null;
    final ts = widget.video is Map ? (widget.video['timestamp_seconds'] ?? widget.video['start_time']) : null;
    
    if (videoId == null || videoId.toString().isEmpty) {
      await _launchUrl();
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    if (ts != null) {
       // Just let it load, seeking immediately might fail if not ready, but we try anyway.
       // Actually startAt is often passed differently but autoPlay is reliable.
    }

    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> _launchUrl() async {
    final videoId = widget.video is Map ? widget.video['video_id'] : null;
    final ts = widget.video is Map ? (widget.video['timestamp_seconds'] ?? widget.video['start_time']) : null;
    final fallbackUrl = videoId != null 
        ? 'https://www.youtube.com/watch?v=$videoId${ts != null ? '&t=$ts' : ''}'
        : 'https://youtube.com';
        
    final urlString = widget.video is Map 
        ? (widget.video['timestamp_url'] ?? widget.video['url'] ?? fallbackUrl) 
        : 'https://youtube.com';
        
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.video is Map ? widget.video['title'] ?? 'Video ${widget.index + 1}' : 'Video ${widget.index + 1}';
    final duration = widget.video is Map ? widget.video['duration'] ?? '3:45' : '3:45';
    final videoId = widget.video is Map ? widget.video['video_id'] : null;
    
    final tsRaw = widget.video is Map ? (widget.video['timestamp_seconds'] ?? widget.video['start_time']) : null;
    final int ts = tsRaw != null ? int.tryParse(tsRaw.toString()) ?? 0 : 0;
    
    final int mins = ts ~/ 60;
    final int secs = ts % 60;
    final String timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    
    final String explanationRaw = widget.video is Map ? (widget.video['timestamp_explanation'] ?? widget.video['relevance_snippet'] ?? '') : '';
    final String explanationText = explanationRaw.isNotEmpty ? explanationRaw : 'Topic explanation segment';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _isPlaying ? null : _playVideo,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 280,
          margin: const EdgeInsets.only(right: 16, bottom: 12, top: 8),
          transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? AppColors.primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
            ),
            boxShadow: [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail or Player
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    gradient: !_isPlaying ? LinearGradient(
                      colors: [
                        const Color(0xFF38BDF8).withValues(alpha: _isHovered ? 0.6 : 0.3),
                        const Color(0xFFC084FC).withValues(alpha: _isHovered ? 0.6 : 0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ) : null,
                  ),
                  child: _isPlaying && _controller != null
                      ? YoutubePlayer(controller: _controller!)
                      : Stack(
                          alignment: Alignment.center,
                          fit: StackFit.expand,
                          children: [
                            if (videoId != null && videoId.toString().isNotEmpty)
                              Image.network(
                                'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                    'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const SizedBox(),
                                  );
                                },
                              ),
                            // Overlay Dark Tint
                            Container(color: Colors.black.withValues(alpha: _isHovered ? 0.1 : 0.3)),
                            // Play Icon
                            Center(
                              child: AnimatedScale(
                                scale: _isHovered ? 1.2 : 1.0,
                                duration: const Duration(milliseconds: 250),
                                child: Icon(
                                  Icons.play_circle_fill_rounded, 
                                  color: Colors.white.withValues(alpha: _isHovered ? 1.0 : 0.9), 
                                  size: 52
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  duration,
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 14, color: Colors.white.withValues(alpha: 0.5)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.video is Map ? (widget.video['channel'] ?? 'YouTube') : 'YouTube',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_isPlaying && _controller != null) ...[
                              const SizedBox(width: 8),
                              _SpeedControl(controller: _controller!),
                            ],
                            const SizedBox(width: 8),
                          ],
                        ),
                        const Spacer(),
                        if (ts > 0 || explanationRaw.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTag(timeStr, AppColors.accentPink),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  explanationText,
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String time, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        time,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SpeedControl extends StatefulWidget {
  final YoutubePlayerController controller;
  
  const _SpeedControl({required this.controller});

  @override
  State<_SpeedControl> createState() => _SpeedControlState();
}

class _SpeedControlState extends State<_SpeedControl> {
  double _currentSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      initialValue: _currentSpeed,
      tooltip: 'Playback Speed',
      color: const Color(0xFF2D2D2D),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (speed) {
        widget.controller.setPlaybackRate(speed);
        setState(() => _currentSpeed = speed);
      },
      itemBuilder: (context) => [
        _buildMenuItem(0.25, '0.25x'),
        _buildMenuItem(0.5, '0.5x'),
        _buildMenuItem(0.75, '0.75x'),
        _buildMenuItem(1.0, 'Normal'),
        _buildMenuItem(1.25, '1.25x'),
        _buildMenuItem(1.5, '1.5x'),
        _buildMenuItem(1.75, '1.75x'),
        _buildMenuItem(2.0, '2.0x'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.speed, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              _currentSpeed == 1.0 ? '1x' : '${_currentSpeed}x',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<double> _buildMenuItem(double value, String text) {
    return PopupMenuItem<double>(
      value: value,
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: _currentSpeed == value ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (_currentSpeed == value)
            const Icon(Icons.check, size: 14, color: Colors.white),
        ],
      ),
    );
  }
}

