import 'package:flutter/material.dart';
import 'package:hidi/features/search/models/search_models.dart';

/// 검색 결과 없음 뷰
class SearchEmptyView extends StatelessWidget {
  final String query;
  final SearchCategory? category;
  final List<String> suggestedKeywords;
  final ValueChanged<String>? onKeywordTap;

  const SearchEmptyView({
    super.key,
    required this.query,
    this.category,
    this.suggestedKeywords = const [],
    this.onKeywordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(),
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '다른 키워드로 검색해보세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            if (suggestedKeywords.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                '추천 검색어',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: suggestedKeywords.map((keyword) {
                  return ActionChip(
                    label: Text('#$keyword'),
                    onPressed: () => onKeywordTap?.call(keyword),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (category) {
      case SearchCategory.songs:
        return Icons.music_note;
      case SearchCategory.artists:
        return Icons.person;
      case SearchCategory.posts:
        return Icons.article;
      case SearchCategory.users:
        return Icons.people;
      default:
        return Icons.search_off;
    }
  }

  String _getEmptyMessage() {
    final categoryName = category?.label ?? '전체';
    if (category == null || category == SearchCategory.all) {
      return '"$query"에 대한\n검색 결과가 없습니다';
    }
    return '"$query" $categoryName 검색 결과가\n없습니다';
  }
}

/// 최근 검색어 없음 뷰
class RecentSearchEmptyView extends StatelessWidget {
  const RecentSearchEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '최근 검색어가 없습니다',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '노래, 아티스트, 게시글, 사용자를\n검색해보세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 검색 에러 뷰
class SearchErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const SearchErrorView({
    super.key,
    this.message = '검색 중 오류가 발생했습니다',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
