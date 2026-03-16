import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 유튜브 영상 섹션 위젯 (F15)
/// 유튜브 플레이어 패키지 없이 썸네일 + 외부 링크 방식으로 구현
class YoutubeSection extends StatelessWidget {
  final String youtubeUrl;

  const YoutubeSection({
    super.key,
    required this.youtubeUrl,
  });

  String? get _videoId {
    final uri = Uri.tryParse(youtubeUrl);
    if (uri == null) return null;
    // youtube.com/watch?v=VIDEO_ID
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }
    // youtu.be/VIDEO_ID
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return null;
  }

  String get _thumbnailUrl {
    final id = _videoId;
    if (id != null) {
      return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
    }
    return '';
  }

  Future<void> _openYoutube() async {
    final uri = Uri.parse(youtubeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.play_circle_fill, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '뮤직비디오',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _openYoutube,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildThumbnail(),
                  // 재생 버튼 오버레이
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // YouTube 로고
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'YouTube',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail() {
    final thumbnail = _thumbnailUrl;
    if (thumbnail.isNotEmpty) {
      return Image.network(
        thumbnail,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.videocam_off, size: 48, color: Colors.grey),
      ),
    );
  }
}
