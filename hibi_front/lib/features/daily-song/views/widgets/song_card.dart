import 'package:flutter/material.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';
import 'package:hidi/features/daily-song/views/widgets/like_button.dart';

/// 홈 화면에서 사용하는 노래 카드 컴포넌트
class SongCard extends StatelessWidget {
  final DailySong song;
  final VoidCallback onTap;
  final VoidCallback onLikeTap;
  final VoidCallback? onArtistTap;

  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
    required this.onLikeTap,
    this.onArtistTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 앨범 이미지
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Hero(
                tag: 'album-${song.id}',
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _buildAlbumImage(),
                ),
              ),
            ),

            // 곡 정보
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 곡 제목 (한글)
                  Text(
                    song.titleKor,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 곡 제목 (일본어)
                  Text(
                    song.titleJp,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // 아티스트
                  GestureDetector(
                    onTap: onArtistTap,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            song.artist.nameKor.isNotEmpty
                                ? song.artist.nameKor[0]
                                : '?',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            song.artist.nameKor,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: onArtistTap != null
                                  ? colorScheme.primary
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onArtistTap != null)
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 앨범 정보
                  Text(
                    '${song.album.name} · ${song.album.releaseDate.year}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // 좋아요 버튼
                  Center(
                    child: LikeButton(
                      isLiked: song.isLiked,
                      onTap: onLikeTap,
                      likeCount: song.likeCount,
                      showCount: true,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumImage() {
    // Mock에서는 asset 이미지 사용, 실제로는 네트워크 이미지
    if (song.album.imageUrl.startsWith('assets/')) {
      return Image.asset(
        song.album.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else if (song.album.imageUrl.isNotEmpty) {
      return Image.network(
        song.album.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 64,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
