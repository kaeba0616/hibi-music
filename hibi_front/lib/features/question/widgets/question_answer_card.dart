import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/question_models.dart';

/// 문의 답변 카드 위젯
class QuestionAnswerCard extends StatelessWidget {
  final Question question;

  const QuestionAnswerCard({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    // 답변이 있는 경우
    if (question.answer != null && question.answer!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  '운영팀 답변',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            if (question.answeredAt != null) ...[
              const SizedBox(height: 4),
              Text(
                DateFormat('yyyy.MM.dd HH:mm').format(question.answeredAt!),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              question.answer!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
    }

    // 답변 대기 중인 경우
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 24,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '운영팀에서 문의 내용을 검토 중입니다',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '빠른 시일 내에 답변 드리겠습니다.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
