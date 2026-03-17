import 'package:flutter/material.dart';

/// 신고 사유 enum (백엔드 ReportReason과 매핑)
enum CommentReportReason {
  spam('SPAM', '스팸/광고'),
  abuse('ABUSE', '욕설/비방'),
  inappropriate('INAPPROPRIATE', '불쾌한 내용'),
  copyright('COPYRIGHT', '저작권 침해'),
  other('OTHER', '기타');

  final String value;
  final String displayName;
  const CommentReportReason(this.value, this.displayName);
}

/// 댓글 신고 Bottom Sheet - CE-02 (F16)
///
/// 신고 사유를 선택하고, "기타" 선택 시 상세 내용을 입력받는다.
/// 신고 처리는 기존 Report API를 재활용한다.
class CommentReportSheet extends StatefulWidget {
  final int commentId;
  final Future<bool> Function(
    int commentId,
    String reason,
    String? description,
  ) onReport;

  const CommentReportSheet({
    super.key,
    required this.commentId,
    required this.onReport,
  });

  /// Bottom Sheet를 표시하는 헬퍼 메서드
  static Future<void> show({
    required BuildContext context,
    required int commentId,
    required Future<bool> Function(
      int commentId,
      String reason,
      String? description,
    ) onReport,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CommentReportSheet(
        commentId: commentId,
        onReport: onReport,
      ),
    );
  }

  @override
  State<CommentReportSheet> createState() => _CommentReportSheetState();
}

class _CommentReportSheetState extends State<CommentReportSheet> {
  CommentReportReason? _selectedReason;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_selectedReason == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final description = _selectedReason == CommentReportReason.other
          ? _descriptionController.text.trim()
          : null;

      final success = await widget.onReport(
        widget.commentId,
        _selectedReason!.value,
        description,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '신고가 접수되었습니다' : '이미 신고한 댓글입니다',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('신고에 실패했습니다. 다시 시도해주세요'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들 바
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    '댓글 신고',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      size: 24,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 사유 목록
            ...CommentReportReason.values.map((reason) {
              return RadioListTile<CommentReportReason>(
                value: reason,
                groupValue: _selectedReason,
                onChanged: _isSubmitting
                    ? null
                    : (value) => setState(() => _selectedReason = value),
                title: Text(
                  reason.displayName,
                  style: const TextStyle(fontSize: 15),
                ),
                activeColor: colorScheme.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              );
            }),
            // 기타 상세 입력
            if (_selectedReason == CommentReportReason.other)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _descriptionController,
                  enabled: !_isSubmitting,
                  maxLength: 300,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '신고 사유를 입력해주세요',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            // 신고하기 버튼
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed:
                      _selectedReason != null && !_isSubmitting
                          ? _handleSubmit
                          : null,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '신고하기',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
