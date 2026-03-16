import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/question_models.dart';
import 'question_status_badge.dart';

/// 문의 목록 항목 위젯
class QuestionListTile extends StatelessWidget {
  final Question question;
  final VoidCallback? onTap;

  const QuestionListTile({
    super.key,
    required this.question,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단: 유형 아이콘 + 유형 라벨 + 상태 뱃지
              Row(
                children: [
                  Icon(
                    _getTypeIcon(question.type),
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    question.type.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  QuestionStatusBadge(status: question.status),
                ],
              ),
              const SizedBox(height: 10),
              // 제목
              Text(
                question.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // 날짜
              Text(
                DateFormat('yyyy.MM.dd').format(question.createdAt),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.account:
        return Icons.key;
      case QuestionType.service:
        return Icons.phone_android;
      case QuestionType.bug:
        return Icons.bug_report;
      case QuestionType.feature:
        return Icons.lightbulb_outline;
      case QuestionType.other:
        return Icons.edit_note;
    }
  }
}
