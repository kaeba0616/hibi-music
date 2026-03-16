import 'package:flutter/material.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';

/// 캘린더에서 선택된 날짜의 노래 카드
class CalendarSongCard extends StatelessWidget {
  final DailySong song;
  final VoidCallback? onTap;
  final VoidCallback? onArtistTap;
  final VoidCallback? onLikeTap;

  const CalendarSongCard({
    super.key,
    required this.song,
    this.onTap,
    this.onArtistTap,
    this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 앨범 이미지
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: colorScheme.surfaceContainerHighest,
                  child: song.album.imageUrl.isNotEmpty
                      ? Image.network(
                          song.album.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(colorScheme),
                        )
                      : _buildPlaceholder(colorScheme),
                ),
              ),
              const SizedBox(width: 12),
              // 노래 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 한글 제목
                    Text(
                      song.titleKor,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // 일본어 제목
                    Text(
                      song.titleJp,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 아티스트 (탭 가능)
                    GestureDetector(
                      onTap: onArtistTap,
                      child: Text(
                        song.artist.nameKor,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // 앨범 / 연도
                    Text(
                      '${song.album.name} \u00B7 ${song.album.releaseDate.year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 좋아요 버튼
              IconButton(
                onPressed: onLikeTap,
                icon: Icon(
                  song.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: song.isLiked ? Colors.red : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.music_note,
        size: 32,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
