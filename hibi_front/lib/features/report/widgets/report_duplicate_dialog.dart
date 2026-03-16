/// 중복 신고 안내 다이얼로그 위젯
/// AC-F11-7: 이미 신고한 항목일 때 표시

import 'package:flutter/material.dart';

class ReportDuplicateDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ReportDuplicateDialog({
    super.key,
    required this.onConfirm,
  });

  /// 다이얼로그 표시
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ReportDuplicateDialog(
        onConfirm: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 정보 아이콘
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info,
              color: Colors.blue.shade600,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          // 제목
          Text(
            '이미 신고한 항목입니다',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // 설명
          Text(
            '동일한 콘텐츠는 한 번만\n신고하실 수 있습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onConfirm,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              '확인',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
