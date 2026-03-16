import 'package:flutter/material.dart';
import 'package:hidi/features/search/models/search_models.dart';

/// 아티스트 검색 결과 타일
class ArtistSearchTile extends StatelessWidget {
  final SearchArtist artist;
  final VoidCallback onTap;
  final VoidCallback? onFollowTap;
  final bool showFollowButton;

  const ArtistSearchTile({
    super.key,
    required this.artist,
    required this.onTap,
    this.onFollowTap,
    this.showFollowButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: artist.profileUrl != null
            ? NetworkImage(artist.profileUrl!)
            : null,
        child: artist.profileUrl == null
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(
        '${artist.nameEng} (${artist.nameKor})',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${artist.songCount}곡 · 팔로워 ${_formatNumber(artist.followerCount)}',
      ),
      trailing: showFollowButton
          ? _buildFollowButton(context)
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildFollowButton(BuildContext context) {
    if (artist.isFollowing) {
      return OutlinedButton(
        onPressed: onFollowTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(80, 32),
          visualDensity: VisualDensity.compact,
        ),
        child: const Text('팔로잉'),
      );
    } else {
      return FilledButton(
        onPressed: onFollowTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(80, 32),
          visualDensity: VisualDensity.compact,
        ),
        child: const Text('팔로우'),
      );
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
