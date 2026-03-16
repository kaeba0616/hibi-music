import 'package:flutter/material.dart';

/// 문의하기 유도 카드 위젯
class FAQContactCard extends StatelessWidget {
  final VoidCallback? onContactTap;

  const FAQContactCard({
    super.key,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.support_agent,
            size: 32,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            '원하시는 답변을 찾지 못하셨나요?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '고객센터에 문의해주시면 빠르게 답변드리겠습니다.',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onContactTap,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('문의하기'),
          ),
        ],
      ),
    );
  }
}
