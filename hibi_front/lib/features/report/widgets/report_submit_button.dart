/// 신고 제출 버튼 위젯
/// 상태에 따른 활성화/비활성화/로딩 상태 표시

import 'package:flutter/material.dart';

class ReportSubmitButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onPressed;

  const ReportSubmitButton({
    super.key,
    required this.enabled,
    required this.isLoading,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
          disabledBackgroundColor:
              theme.colorScheme.onSurface.withOpacity(0.12),
          disabledForegroundColor:
              theme.colorScheme.onSurface.withOpacity(0.38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onError,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('신고 접수 중...'),
                ],
              )
            : const Text(
                '신고하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
