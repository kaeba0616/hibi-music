import 'package:flutter/material.dart';

/// 월 네비게이션 위젯
class MonthNavigator extends StatelessWidget {
  final int year;
  final int month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTodayTap;

  const MonthNavigator({
    super.key,
    required this.year,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.onTodayTap,
  });

  String get _monthText => '$year년 $month월';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // 이전 월 버튼
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
            tooltip: '이전 월',
          ),
          // 월 표시
          Expanded(
            child: Text(
              _monthText,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 다음 월 버튼
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
            tooltip: '다음 월',
          ),
          // 오늘 버튼
          TextButton(
            onPressed: onTodayTap,
            child: Text(
              '오늘',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
