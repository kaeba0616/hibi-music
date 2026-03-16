import 'package:flutter/material.dart';
import 'package:hidi/features/calendar/widgets/calendar_day_cell.dart';

/// 캘린더 그리드 위젯
class CalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final DateTime? selectedDate;
  final Set<DateTime> markedDates;
  final Set<DateTime>? likedDates;
  final void Function(DateTime) onDateSelected;

  const CalendarGrid({
    super.key,
    required this.year,
    required this.month,
    this.selectedDate,
    required this.markedDates,
    this.likedDates,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 해당 월의 첫 날과 마지막 날
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // 시작 요일 (일요일=0 기준)
    final startWeekday = firstDayOfMonth.weekday % 7;

    // 그리드 아이템 수 (이전 월 날짜 포함)
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final gridCells = rows * 7;

    return Column(
      children: [
        // 요일 헤더
        _buildWeekdayHeader(theme),
        const Divider(height: 1),
        // 날짜 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.85,
          ),
          itemCount: gridCells,
          itemBuilder: (context, index) {
            // 이전 월 날짜
            if (index < startWeekday) {
              final prevMonthDay = DateTime(year, month, 0).day - (startWeekday - index - 1);
              final date = DateTime(year, month - 1, prevMonthDay);
              return CalendarDayCell(
                date: date,
                isOtherMonth: true,
                isDisabled: true,
              );
            }

            // 다음 월 날짜
            final day = index - startWeekday + 1;
            if (day > daysInMonth) {
              final nextMonthDay = day - daysInMonth;
              final date = DateTime(year, month + 1, nextMonthDay);
              return CalendarDayCell(
                date: date,
                isOtherMonth: true,
                isDisabled: true,
              );
            }

            // 현재 월 날짜
            final date = DateTime(year, month, day);
            final isFuture = date.isAfter(today);
            final isSelected = selectedDate != null &&
                selectedDate!.year == date.year &&
                selectedDate!.month == date.month &&
                selectedDate!.day == date.day;
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
            final hasMarker = markedDates.contains(date);
            final isLiked = likedDates?.contains(date) ?? false;

            return CalendarDayCell(
              date: date,
              isSelected: isSelected,
              isToday: isToday,
              hasMarker: hasMarker,
              isLiked: isLiked,
              isDisabled: isFuture,
              onTap: () => onDateSelected(date),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(ThemeData theme) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) {
          final isWeekend = day == '일' || day == '토';
          return SizedBox(
            width: 40,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isWeekend
                    ? theme.colorScheme.error.withOpacity(0.7)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
