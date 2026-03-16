import 'package:flutter/material.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';

/// 연관곡 타일 위젯 (F15)
class RelatedSongTile extends StatelessWidget {
  final RelatedSong song;
  final VoidCallback onTap;

  const RelatedSongTile({
    super.key,
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 48,
          height: 48,
          child: _buildAlbumImage(song.album.imageUrl),
        ),
      ),
      title: Text(
        song.titleKor,
        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            song.artist.nameKor,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            song.reason,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.primary.withOpacity(0.7),
              fontStyle: FontStyle.italic,
              fontSize: 11,
            ),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildAlbumImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.music_note, size: 24, color: Colors.grey),
    );
  }
}
