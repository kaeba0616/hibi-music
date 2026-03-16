import 'package:flutter/material.dart';
import 'package:hidi/features/search/models/search_models.dart';

/// 노래 검색 결과 타일
class SongSearchTile extends StatelessWidget {
  final SearchSong song;
  final VoidCallback onTap;
  final bool showDetails;

  const SongSearchTile({
    super.key,
    required this.song,
    required this.onTap,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: song.albumImageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song.albumImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.album),
                ),
              )
            : const Icon(Icons.album),
      ),
      title: Text(
        '${song.titleKor} (${song.titleJp})',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: showDetails
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${song.artistName} · ${song.albumName} · ${song.releaseYear}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${song.genre ?? 'J-Pop'} · ♡ ${_formatNumber(song.likeCount)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            )
          : Text(
              '${song.artistName} · ${song.albumName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
