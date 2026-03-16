import 'package:flutter/material.dart';

/// FAQ Empty/Error View 위젯
class FAQEmptyView extends StatelessWidget {
  final FAQEmptyType type;
  final String? searchKeyword;
  final VoidCallback? onRetry;
  final VoidCallback? onContactSupport;

  const FAQEmptyView({
    super.key,
    required this.type,
    this.searchKeyword,
    this.onRetry,
    this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIcon(),
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _getTitle(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getSubtitle(),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (type == FAQEmptyType.error && onRetry != null)
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            if (type != FAQEmptyType.error && onContactSupport != null)
              OutlinedButton.icon(
                onPressed: onContactSupport,
                icon: const Icon(Icons.mail_outline),
                label: const Text('문의하기'),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case FAQEmptyType.noFAQs:
        return Icons.description_outlined;
      case FAQEmptyType.noSearchResult:
        return Icons.search_off;
      case FAQEmptyType.error:
        return Icons.error_outline;
    }
  }

  String _getTitle() {
    switch (type) {
      case FAQEmptyType.noFAQs:
        return '등록된 FAQ가 없습니다';
      case FAQEmptyType.noSearchResult:
        return searchKeyword != null
            ? '"$searchKeyword"에 대한 검색 결과가 없습니다'
            : '검색 결과가 없습니다';
      case FAQEmptyType.error:
        return 'FAQ를 불러올 수 없습니다';
    }
  }

  String _getSubtitle() {
    switch (type) {
      case FAQEmptyType.noFAQs:
        return '궁금한 점이 있으시면 문의해주세요';
      case FAQEmptyType.noSearchResult:
        return '다른 키워드로 검색해보세요';
      case FAQEmptyType.error:
        return '네트워크 연결을 확인해주세요';
    }
  }
}

enum FAQEmptyType {
  noFAQs,         // FAQ 없음
  noSearchResult, // 검색 결과 없음
  error,          // 에러
}
