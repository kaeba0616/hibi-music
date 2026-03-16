import 'package:flutter/material.dart';

/// 게시글 없음 Empty View
class PostEmptyView extends StatelessWidget {
  final VoidCallback? onCreateTap;

  const PostEmptyView({
    super.key,
    this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_note,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 게시글이 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '첫 번째 게시글을 작성해보세요!',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (onCreateTap != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onCreateTap,
                icon: const Icon(Icons.add),
                label: const Text('글쓰기'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 게시글 로딩 에러 View
class PostErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const PostErrorView({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? '게시글을 불러올 수 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
