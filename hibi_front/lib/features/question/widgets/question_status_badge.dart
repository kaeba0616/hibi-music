import 'package:flutter/material.dart';
import '../models/question_models.dart';

/// 문의 상태 뱃지 위젯
class QuestionStatusBadge extends StatelessWidget {
  final QuestionStatus status;
  final bool small;

  const QuestionStatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: _getTextColor(context),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (status) {
      case QuestionStatus.received:
        return Colors.grey.shade200;
      case QuestionStatus.processing:
        return Colors.blue.shade100;
      case QuestionStatus.answered:
        return Colors.green.shade100;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (status) {
      case QuestionStatus.received:
        return Colors.grey.shade700;
      case QuestionStatus.processing:
        return Colors.blue.shade700;
      case QuestionStatus.answered:
        return Colors.green.shade700;
    }
  }
}
