import 'package:flutter/material.dart';
import 'package:hidi/features/posts/models/post_models.dart';

/// 노래 태그 카드 컴포넌트
class SongTagCard extends StatelessWidget {
  final TaggedSong song;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool compact;

  const SongTagCard({
    super.key,
    required this.song,
    this.onTap,
    this.onRemove,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(compact ? 8 : 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            // 앨범 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: compact ? 40 : 48,
                height: compact ? 40 : 48,
                color: colorScheme.surfaceContainerHigh,
                child: song.albumImageUrl != null
                    ? Image.network(
                        song.albumImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.album,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Icon(
                        Icons.album,
                        color: colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // 노래 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    song.titleKor,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? 13 : 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    compact
                        ? song.artistName
                        : '${song.artistName}${song.albumName != null ? ' · ${song.albumName}' : ''}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: compact ? 11 : 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 삭제 버튼 (수정 모드에서만)
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 노래 검색 결과 목록 아이템
class SongSearchItem extends StatelessWidget {
  final TaggedSong song;
  final VoidCallback onTap;

  const SongSearchItem({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 48,
          height: 48,
          color: colorScheme.surfaceContainerHigh,
          child: song.albumImageUrl != null
              ? Image.network(
                  song.albumImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.album,
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : Icon(
                  Icons.album,
                  color: colorScheme.onSurfaceVariant,
                ),
        ),
      ),
      title: Text(
        song.titleKor,
        style: const TextStyle(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artistName}${song.albumName != null ? ' · ${song.albumName}' : ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
