import 'package:flutter/material.dart';

/// 언팔로우 확인 다이얼로그 (FO-03)
class UnfollowDialog extends StatelessWidget {
  final String username;
  final VoidCallback? onConfirm;

  const UnfollowDialog({
    super.key,
    required this.username,
    this.onConfirm,
  });

  /// 다이얼로그 표시 헬퍼
  static Future<bool?> show(BuildContext context, String username) {
    return showDialog<bool>(
      context: context,
      builder: (_) => UnfollowDialog(username: username),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        '@$username님을\n언팔로우하시겠습니까?',
        style: const TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
      content: Text(
        '언팔로우하면 이 사용자의\n게시글이 피드에서 사라집니다.',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            '취소',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          child: const Text(
            '언팔로우',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
