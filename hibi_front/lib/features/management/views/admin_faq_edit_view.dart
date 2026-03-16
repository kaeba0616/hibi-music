/// MG-07: FAQ 편집 화면

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../faq/models/faq_models.dart';
import '../viewmodels/admin_faq_viewmodel.dart';

class AdminFAQEditView extends ConsumerStatefulWidget {
  final int? faqId; // null이면 생성, 값이 있으면 수정

  const AdminFAQEditView({
    super.key,
    this.faqId,
  });

  @override
  ConsumerState<AdminFAQEditView> createState() => _AdminFAQEditViewState();
}

class _AdminFAQEditViewState extends ConsumerState<AdminFAQEditView> {
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _orderController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    if (widget.faqId != null) {
      Future.microtask(() {
        ref.read(faqEditViewModelProvider(widget.faqId).notifier).loadFaq();
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(faqEditViewModelProvider(widget.faqId));
    final theme = Theme.of(context);

    // 수정 모드일 때 데이터 로드 후 텍스트 필드 동기화
    if (state.originalFaq != null &&
        _questionController.text.isEmpty &&
        _answerController.text.isEmpty) {
      _questionController.text = state.question;
      _answerController.text = state.answer;
      _orderController.text = state.displayOrder.toString();
    }

    // 저장 완료 시 뒤로가기
    ref.listen(faqEditViewModelProvider(widget.faqId), (prev, next) {
      if (next.isSaved && prev?.isSaved != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.faqId != null ? 'FAQ가 수정되었습니다' : 'FAQ가 등록되었습니다',
            ),
          ),
        );
        context.pop();
      }
      if (next.errorMessage != null && prev?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.faqId != null ? 'FAQ 수정' : 'FAQ 등록'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 선택
                  Text(
                    '카테고리',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<FAQCategory>(
                    value: state.category,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: FAQCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(_getCategoryLabel(category)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(faqEditViewModelProvider(widget.faqId).notifier)
                            .updateCategory(value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  // 질문
                  Text(
                    '질문',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '자주 묻는 질문을 입력해주세요',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      ref
                          .read(faqEditViewModelProvider(widget.faqId).notifier)
                          .updateQuestion(value);
                    },
                  ),
                  const SizedBox(height: 24),
                  // 답변
                  Text(
                    '답변',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _answerController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: '답변을 입력해주세요',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      ref
                          .read(faqEditViewModelProvider(widget.faqId).notifier)
                          .updateAnswer(value);
                    },
                  ),
                  const SizedBox(height: 24),
                  // 표시 순서
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '표시 순서',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _orderController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final order = int.tryParse(value) ?? 1;
                                ref
                                    .read(faqEditViewModelProvider(widget.faqId)
                                        .notifier)
                                    .updateDisplayOrder(order);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 공개 여부
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '공개 여부',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SwitchListTile(
                              value: state.isPublished,
                              onChanged: (value) {
                                ref
                                    .read(faqEditViewModelProvider(widget.faqId)
                                        .notifier)
                                    .updateIsPublished(value);
                              },
                              title: Text(state.isPublished ? '공개' : '비공개'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // 저장 버튼
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () {
                              ref
                                  .read(
                                      faqEditViewModelProvider(widget.faqId).notifier)
                                  .save();
                            },
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.faqId != null ? '수정' : '등록'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _getCategoryLabel(FAQCategory category) {
    switch (category) {
      case FAQCategory.account:
        return '계정';
      case FAQCategory.service:
        return '서비스';
      case FAQCategory.music:
        return '음악';
      case FAQCategory.community:
        return '커뮤니티';
      case FAQCategory.other:
        return '기타';
    }
  }
}
