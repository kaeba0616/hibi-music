import 'package:flutter/material.dart';

/// 로그인 필요 다이얼로그 (AC-F10-7)
class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const LoginRequiredDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        '로그인이 필요합니다',
        textAlign: TextAlign.center,
      ),
      content: const Text(
        '문의하기 기능을 이용하시려면\n로그인이 필요합니다.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('로그인'),
        ),
      ],
    );
  }
}
