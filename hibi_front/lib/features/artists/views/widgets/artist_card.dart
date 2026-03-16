import 'package:flutter/material.dart';
import 'package:hidi/features/artists/models/artist_model.dart';

/// 아티스트 카드 위젯 (AR-01 목록용)
class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback? onTap;

  const ArtistCard({
    super.key,
    required this.artist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 프로필 이미지
              Hero(
                tag: 'artist_${artist.id}',
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: artist.profileImage != null
                      ? NetworkImage(artist.profileImage!)
                      : null,
                  child: artist.profileImage == null
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              // 아티스트 이름
              Text(
                artist.nameKor,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // 곡 수
              Text(
                '${artist.songCount}곡',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              // 팔로우 상태 아이콘
              if (artist.isFollowing)
                Icon(
                  Icons.favorite,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
