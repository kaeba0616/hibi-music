/// 신고 상세 내용 입력 필드 위젯
/// "기타" 사유 선택 시 표시되는 TextArea

import 'package:flutter/material.dart';

class ReportDescriptionField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final int maxLength;

  const ReportDescriptionField({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.maxLength = 300,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '상세 내용 (선택)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        // 텍스트 입력 필드
        TextField(
          enabled: enabled,
          maxLines: 4,
          maxLength: maxLength,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '신고 사유를 상세히 적어주세요',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.dividerColor.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
