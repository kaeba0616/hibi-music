/// 신고 사유 선택 타일 위젯
/// RP-01 화면의 라디오 버튼 목록 항목

import 'package:flutter/material.dart';

import '../models/report_models.dart';

class ReportReasonTile extends StatelessWidget {
  final ReportReason reason;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enabled;

  const ReportReasonTile({
    super.key,
    required this.reason,
    required this.isSelected,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withOpacity(0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // 라디오 버튼 아이콘
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? theme.colorScheme.primary
                  : (enabled
                      ? theme.colorScheme.onSurface.withOpacity(0.6)
                      : theme.disabledColor),
              size: 24,
            ),
            const SizedBox(width: 12),
            // 사유 텍스트
            Expanded(
              child: Text(
                reason.displayName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: enabled
                      ? theme.colorScheme.onSurface
                      : theme.disabledColor,
                ),
              ),
            ),
            // 선택됨 표시
            if (isSelected)
              Icon(
                Icons.check,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
