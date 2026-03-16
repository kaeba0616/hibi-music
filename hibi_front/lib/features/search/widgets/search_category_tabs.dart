import 'package:flutter/material.dart';
import 'package:hidi/features/search/models/search_models.dart';

/// 검색 카테고리 탭
class SearchCategoryTabs extends StatelessWidget {
  final SearchCategory selectedCategory;
  final ValueChanged<SearchCategory> onCategoryChanged;
  final SearchResult? result;

  const SearchCategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: SearchCategory.values.map((category) {
          final isSelected = selectedCategory == category;
          final count = _getCategoryCount(category);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                count != null && count > 0
                    ? '${category.label} $count'
                    : category.label,
              ),
              onSelected: (_) => onCategoryChanged(category),
            ),
          );
        }).toList(),
      ),
    );
  }

  int? _getCategoryCount(SearchCategory category) {
    if (result == null) return null;

    switch (category) {
      case SearchCategory.all:
        return result!.totalCount;
      case SearchCategory.songs:
        return result!.totalSongs;
      case SearchCategory.artists:
        return result!.totalArtists;
      case SearchCategory.posts:
        return result!.totalPosts;
      case SearchCategory.users:
        return result!.totalUsers;
    }
  }
}
