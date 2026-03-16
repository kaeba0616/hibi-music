/// 상태 배지 위젯

import 'package:flutter/material.dart';

import '../../question/models/question_models.dart';
import '../../report/models/report_models.dart';
import '../models/admin_models.dart';

/// 범용 상태 배지
class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 신고 상태 배지
class ReportStatusBadge extends StatelessWidget {
  final ReportStatus status;

  const ReportStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case ReportStatus.pending:
        backgroundColor = theme.colorScheme.error.withOpacity(0.1);
        textColor = theme.colorScheme.error;
        label = '대기중';
      case ReportStatus.inReview:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        label = '검토중';
      case ReportStatus.resolved:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        label = '처리완료';
      case ReportStatus.dismissed:
        backgroundColor = theme.colorScheme.onSurface.withOpacity(0.1);
        textColor = theme.colorScheme.onSurface.withOpacity(0.6);
        label = '기각';
    }

    return StatusBadge(
      label: label,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}

/// 문의 상태 배지
class QuestionStatusBadge extends StatelessWidget {
  final QuestionStatus status;

  const QuestionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case QuestionStatus.pending:
        backgroundColor = theme.colorScheme.error.withOpacity(0.1);
        textColor = theme.colorScheme.error;
        label = '답변대기';
      case QuestionStatus.answered:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        label = '답변완료';
    }

    return StatusBadge(
      label: label,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}

/// 회원 상태 배지
class MemberStatusBadge extends StatelessWidget {
  final MemberStatus status;

  const MemberStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case MemberStatus.active:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        label = '활성';
      case MemberStatus.suspended:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        label = '정지';
      case MemberStatus.banned:
        backgroundColor = theme.colorScheme.error.withOpacity(0.1);
        textColor = theme.colorScheme.error;
        label = '탈퇴';
    }

    return StatusBadge(
      label: label,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}

/// 공개 상태 배지
class PublishedBadge extends StatelessWidget {
  final bool isPublished;

  const PublishedBadge({super.key, required this.isPublished});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StatusBadge(
      label: isPublished ? '공개' : '비공개',
      backgroundColor: isPublished
          ? Colors.green.withOpacity(0.1)
          : theme.colorScheme.onSurface.withOpacity(0.1),
      textColor: isPublished
          ? Colors.green.shade700
          : theme.colorScheme.onSurface.withOpacity(0.6),
    );
  }
}
