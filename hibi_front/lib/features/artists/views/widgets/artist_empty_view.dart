import 'package:flutter/material.dart';

/// 아티스트 목록 Empty 뷰
class ArtistEmptyView extends StatelessWidget {
  final bool isFollowingFilter;
  final String? searchQuery;

  const ArtistEmptyView({
    super.key,
    this.isFollowingFilter = false,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String title;
    String? subtitle;
    IconData icon;

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      // 검색 결과 없음
      icon = Icons.search_off;
      title = '"$searchQuery"에 대한 결과가 없습니다';
      subtitle = null;
    } else if (isFollowingFilter) {
      // 팔로우 중인 아티스트 없음
      icon = Icons.favorite_border;
      title = '팔로우 중인 아티스트가 없습니다';
      subtitle = '아티스트를 팔로우해보세요!';
    } else {
      // 아티스트 없음
      icon = Icons.mic_off;
      title = '등록된 아티스트가 없습니다';
      subtitle = null;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
