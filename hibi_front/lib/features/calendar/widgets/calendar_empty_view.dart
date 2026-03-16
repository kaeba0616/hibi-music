import 'package:flutter/material.dart';

/// 캘린더 Empty 상태 위젯
class CalendarEmptyView extends StatelessWidget {
  final CalendarEmptyType type;

  const CalendarEmptyView({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String icon;
    String message;
    String? subMessage;

    switch (type) {
      case CalendarEmptyType.noSongForDate:
        icon = '\uD83D\uDCC5'; // 📅
        message = '해당 날짜에는 추천곡이 없습니다';
        subMessage = null;
      case CalendarEmptyType.noSongForMonth:
        icon = '\uD83C\uDFB5'; // 🎵
        message = '이 달에는 추천곡이 없습니다';
        subMessage = null;
      case CalendarEmptyType.noLikedSongs:
        icon = '\uD83D\uDC94'; // 💔
        message = '좋아요한 노래가 없습니다';
        subMessage = '노래에 좋아요를 눌러보세요!';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (subMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              subMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

enum CalendarEmptyType {
  noSongForDate,
  noSongForMonth,
  noLikedSongs,
}
