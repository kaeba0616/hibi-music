/// 관리자 신고 목록 타일 위젯

import 'package:flutter/material.dart';

import '../../report/models/report_models.dart';
import '../models/admin_report_models.dart';
import 'status_badge.dart';

class AdminReportTile extends StatelessWidget {
  final AdminReportItem report;
  final VoidCallback onTap;

  const AdminReportTile({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTargetTypeIcon(theme),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getTargetTypeLabel(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  ReportStatusBadge(status: report.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getReasonLabel(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '신고자: ${report.reporterNickname}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(report.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetTypeIcon(ThemeData theme) {
    IconData icon;
    switch (report.targetType) {
      case ReportTargetType.comment:
        icon = Icons.comment;
      case ReportTargetType.song:
        icon = Icons.music_note;
      case ReportTargetType.member:
        icon = Icons.person;
    }
    return Icon(
      icon,
      size: 16,
      color: theme.colorScheme.primary,
    );
  }

  String _getTargetTypeLabel() {
    switch (report.targetType) {
      case ReportTargetType.comment:
        return '댓글 신고';
      case ReportTargetType.song:
        return '노래 신고';
      case ReportTargetType.member:
        return '사용자 신고';
    }
  }

  String _getReasonLabel() {
    switch (report.reason) {
      case ReportReason.spam:
        return '스팸/광고';
      case ReportReason.abuse:
        return '욕설/비방';
      case ReportReason.inappropriate:
        return '부적절한 내용';
      case ReportReason.copyright:
        return '저작권 침해';
      case ReportReason.other:
        return '기타';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
