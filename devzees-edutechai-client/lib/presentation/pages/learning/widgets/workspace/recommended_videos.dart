import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/text_styles.dart';

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
            const Text('🎬', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Recommended Video Clips & Timestamps',
                style: AppTextStyles.h3.copyWith(
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos!.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final video = videos![index];
            return _VideoCard(video: video, index: index);
          },
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
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    if (ts != null) {
       // AutoPlay is enabled
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
    final title = widget.video is Map ? (widget.video['title']?.toString() ?? 'Video ${widget.index + 1}') : 'Video ${widget.index + 1}';
    final duration = widget.video is Map ? (widget.video['duration']?.toString() ?? '3:45') : '3:45';
    final videoId = widget.video is Map ? widget.video['video_id']?.toString() : null;
    
    final tsRaw = widget.video is Map ? (widget.video['timestamp_seconds'] ?? widget.video['start_time']) : null;
    final int ts = tsRaw != null ? int.tryParse(tsRaw.toString()) ?? 0 : 0;
    
    final int mins = ts ~/ 60;
    final int secs = ts % 60;
    final String timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    
    final String explanationRaw = widget.video is Map ? (widget.video['timestamp_explanation']?.toString() ?? widget.video['relevance_snippet']?.toString() ?? '') : '';
    final String explanationText = explanationRaw.isNotEmpty ? explanationRaw : 'Topic explanation segment';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _isPlaying ? null : _playVideo,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          margin: EdgeInsets.zero,
          transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.glassSurface.withValues(alpha: 0.08) : AppColors.glassSurface.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? AppColors.primary.withValues(alpha: 0.5) : AppColors.glassBorder,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail or Player (16:9 aspect ratio fills container width proportionally)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      gradient: !_isPlaying ? LinearGradient(
                        colors: [
                          AppColors.cyanLight.withValues(alpha: _isHovered ? 0.6 : 0.3),
                          AppColors.purpleLight.withValues(alpha: _isHovered ? 0.6 : 0.3),
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
                                  scale: _isHovered ? 1.15 : 1.0,
                                  duration: const Duration(milliseconds: 250),
                                  child: Icon(
                                    Icons.play_circle_fill_rounded, 
                                    color: Colors.white.withValues(alpha: _isHovered ? 1.0 : 0.9), 
                                    size: 56,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    duration,
                                    style: AppTextStyles.badge,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                // Info
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.subtitle1.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.video is Map ? (widget.video['channel'] ?? 'YouTube') : 'YouTube',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_isPlaying && _controller != null) ...[
                            const SizedBox(width: 8),
                            _SpeedControl(controller: _controller!),
                          ],
                        ],
                      ),
                      if (ts > 0 || explanationRaw.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.glassBase,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTag(timeStr, AppColors.accentPink),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  explanationText,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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
        style: AppTextStyles.badge.copyWith(
          color: color,
          fontSize: 11,
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
      color: AppColors.surfaceMid,
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
          color: AppColors.glassSurface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.speed, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              _currentSpeed == 1.0 ? '1x' : '${_currentSpeed}x',
              style: AppTextStyles.badge,
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
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
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

