import 'package:flutter/material.dart';
import '../models/faq_models.dart';

/// FAQ 카테고리 헤더 위젯
class FAQCategoryHeader extends StatelessWidget {
  final FAQCategory category;
  final int count;

  const FAQCategoryHeader({
    super.key,
    required this.category,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            category.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(FAQCategory category) {
    switch (category) {
      case FAQCategory.all:
        return Icons.list;
      case FAQCategory.account:
        return Icons.person_outline;
      case FAQCategory.service:
        return Icons.music_note_outlined;
      case FAQCategory.community:
        return Icons.people_outline;
      case FAQCategory.other:
        return Icons.help_outline;
    }
  }
}
