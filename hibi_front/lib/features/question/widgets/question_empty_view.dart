import 'package:flutter/material.dart';

/// 문의 Empty/Error View 위젯
class QuestionEmptyView extends StatelessWidget {
  final bool isError;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onCreateQuestion;

  const QuestionEmptyView({
    super.key,
    this.isError = false,
    this.message,
    this.onRetry,
    this.onCreateQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isError ? Icons.warning_amber_rounded : Icons.description_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message ??
                  (isError ? '문의 내역을 불러올 수 없습니다' : '문의 내역이 없습니다'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isError) ...[
              const SizedBox(height: 8),
              Text(
                '궁금한 점이 있으시면 문의해주세요',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            if (isError && onRetry != null)
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              )
            else if (onCreateQuestion != null)
              ElevatedButton.icon(
                onPressed: onCreateQuestion,
                icon: const Icon(Icons.edit),
                label: const Text('문의하기'),
              ),
          ],
        ),
      ),
    );
  }
}
