import 'package:flutter/material.dart';
import '../models/question_models.dart';

/// 문의 유형 선택 위젯
class QuestionTypeSelector extends StatelessWidget {
  final QuestionType? selectedType;
  final ValueChanged<QuestionType> onSelected;
  final String? errorText;

  const QuestionTypeSelector({
    super.key,
    this.selectedType,
    required this.onSelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '문의 유형 *',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showTypeBottomSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null
                    ? Theme.of(context).colorScheme.error
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (selectedType != null) ...[
                  Icon(
                    _getTypeIcon(selectedType!),
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    selectedType?.label ?? '유형을 선택해주세요',
                    style: TextStyle(
                      color: selectedType != null
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  IconData _getTypeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.account:
        return Icons.key;
      case QuestionType.service:
        return Icons.phone_android;
      case QuestionType.bug:
        return Icons.bug_report;
      case QuestionType.feature:
        return Icons.lightbulb_outline;
      case QuestionType.other:
        return Icons.edit_note;
    }
  }

  void _showTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TypeBottomSheet(
        selectedType: selectedType,
        onSelected: (type) {
          onSelected(type);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _TypeBottomSheet extends StatelessWidget {
  final QuestionType? selectedType;
  final ValueChanged<QuestionType> onSelected;

  const _TypeBottomSheet({
    this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '문의 유형 선택',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...QuestionType.values.map(
              (type) => ListTile(
                leading: Icon(_getTypeIcon(type)),
                title: Text(type.label),
                trailing: selectedType == type
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => onSelected(type),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.account:
        return Icons.key;
      case QuestionType.service:
        return Icons.phone_android;
      case QuestionType.bug:
        return Icons.bug_report;
      case QuestionType.feature:
        return Icons.lightbulb_outline;
      case QuestionType.other:
        return Icons.edit_note;
    }
  }
}
