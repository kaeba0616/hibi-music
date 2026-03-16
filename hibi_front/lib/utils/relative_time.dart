/// 상대 시간 포맷팅 유틸리티
String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return '방금 전';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}분 전';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}시간 전';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}일 전';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks주 전';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months개월 전';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years년 전';
  }
}

/// 절대 시간 포맷팅 (게시글 상세용)
String formatAbsoluteTime(DateTime dateTime) {
  final year = dateTime.year;
  final month = dateTime.month;
  final day = dateTime.day;
  final hour = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');

  final period = hour < 12 ? '오전' : '오후';
  final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

  return '$year년 $month월 $day일 $period $displayHour:$minute';
}
