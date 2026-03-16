import 'package:flutter/material.dart';

/// 캘린더 날짜 셀 위젯
class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool hasMarker;
  final bool isLiked;
  final bool isDisabled;
  final bool isOtherMonth;
  final VoidCallback? onTap;

  const CalendarDayCell({
    super.key,
    required this.date,
    this.isSelected = false,
    this.isToday = false,
    this.hasMarker = false,
    this.isLiked = false,
    this.isDisabled = false,
    this.isOtherMonth = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 텍스트 색상 결정
    Color textColor;
    if (isDisabled || isOtherMonth) {
      textColor = colorScheme.onSurface.withOpacity(0.3);
    } else if (isSelected) {
      textColor = colorScheme.onPrimary;
    } else {
      textColor = colorScheme.onSurface;
    }

    // 배경 색상 및 테두리
    BoxDecoration? decoration;
    if (isSelected) {
      decoration = BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        border: Border.all(color: colorScheme.primary, width: 2),
        shape: BoxShape.circle,
      );
    }

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.all(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 날짜 숫자
            Container(
              width: 32,
              height: 32,
              decoration: decoration,
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // 마커
            if (hasMarker)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isLiked
                      ? Colors.red.shade400
                      : colorScheme.primary.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
