/// 신고 완료 다이얼로그 위젯
/// RP-02 화면: 신고 접수 완료 안내

import 'package:flutter/material.dart';

class ReportSuccessDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ReportSuccessDialog({
    super.key,
    required this.onConfirm,
  });

  /// 다이얼로그 표시
  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReportSuccessDialog(
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
          // 성공 아이콘
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          // 제목
          Text(
            '신고가 접수되었습니다',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // 설명
          Text(
            '신고 내용은 운영팀에서 검토 후\n적절한 조치를 취하겠습니다.',
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
