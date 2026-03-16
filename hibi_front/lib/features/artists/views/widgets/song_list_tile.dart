import 'package:flutter/material.dart';
import 'package:hidi/features/artists/models/artist_song_model.dart';

/// 노래 리스트 타일 위젯 (AR-02 상세화면용)
class SongListTile extends StatelessWidget {
  final ArtistSong song;
  final VoidCallback? onTap;

  const SongListTile({
    super.key,
    required this.song,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 48,
            height: 48,
            color: theme.colorScheme.surfaceContainerHighest,
            child: song.albumImageUrl != null
                ? Image.network(
                    song.albumImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.album,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : Icon(
                    Icons.album,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
        title: Text(
          song.titleKor,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${song.albumName} · ${song.releaseYear}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
