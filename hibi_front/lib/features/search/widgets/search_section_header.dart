import 'package:flutter/material.dart';

/// 검색 결과 섹션 헤더
class SearchSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback? onMoreTap;

  const SearchSectionHeader({
    super.key,
    required this.title,
    required this.count,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title ($count건)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (onMoreTap != null)
            TextButton(
              onPressed: onMoreTap,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('더보기'),
                  Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
