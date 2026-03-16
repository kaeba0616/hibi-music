import 'package:flutter/material.dart';
import 'package:hidi/features/search/models/search_models.dart';

/// 최근 검색어 아이템
class RecentSearchItem extends StatelessWidget {
  final RecentSearch recentSearch;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RecentSearchItem({
    super.key,
    required this.recentSearch,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history, size: 20),
      title: Text(recentSearch.query),
      trailing: IconButton(
        onPressed: onDelete,
        icon: const Icon(Icons.close, size: 18),
        visualDensity: VisualDensity.compact,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// 최근 검색어 섹션 헤더
class RecentSearchHeader extends StatelessWidget {
  final VoidCallback onClearAll;

  const RecentSearchHeader({
    super.key,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '최근 검색어',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            onPressed: onClearAll,
            child: const Text('전체 삭제'),
          ),
        ],
      ),
    );
  }
}
