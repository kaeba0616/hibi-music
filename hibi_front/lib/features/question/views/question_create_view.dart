import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question_models.dart';
import '../viewmodels/question_viewmodel.dart';
import '../widgets/question_type_selector.dart';

/// QU-01: 문의 작성 화면
class QuestionCreateView extends ConsumerStatefulWidget {
  const QuestionCreateView({super.key});

  @override
  ConsumerState<QuestionCreateView> createState() => _QuestionCreateViewState();
}

class _QuestionCreateViewState extends ConsumerState<QuestionCreateView> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    // 오늘의 문의 작성 수 로드
    Future.microtask(() {
      ref.read(questionDailyCountProvider.notifier).loadTodayCount();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(questionFormProvider);
    final dailyCount = ref.watch(questionDailyCountProvider);
    final isLimitReached = dailyCount >= 3;

    // 제출 완료 시 완료 화면으로 이동
    ref.listen<QuestionFormState>(questionFormProvider, (previous, next) {
      if (next.submittedQuestion != null &&
          previous?.submittedQuestion == null) {
        Navigator.pushReplacementNamed(
          context,
          '/question/complete',
          arguments: next.submittedQuestion,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('문의하기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 문의 유형 선택
            QuestionTypeSelector(
              selectedType: formState.selectedType,
              onSelected: (type) {
                ref.read(questionFormProvider.notifier).setType(type);
              },
              errorText: _showErrors ? formState.typeError : null,
            ),

            const SizedBox(height: 24),

            // 제목 입력
            Text(
              '제목 *',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: '문의 제목을 입력해주세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _showErrors ? formState.titleError : null,
                counterText: '${formState.title.length}/100',
              ),
              onChanged: (value) {
                ref.read(questionFormProvider.notifier).setTitle(value);
              },
            ),

            const SizedBox(height: 24),

            // 내용 입력
            Text(
              '내용 *',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLength: 1000,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '문의 내용을 상세히 작성해주세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _showErrors ? formState.contentError : null,
                counterText: '${formState.content.length}/1000',
                alignLabelWithHint: true,
              ),
              onChanged: (value) {
                ref.read(questionFormProvider.notifier).setContent(value);
              },
            ),

            const SizedBox(height: 24),

            // 일일 문의 카운터 (F17)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isLimitReached
                    ? Colors.red.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_note,
                    size: 20,
                    color: isLimitReached
                        ? Colors.red.shade700
                        : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isLimitReached
                        ? '오늘의 문의 작성 한도(3개)를 초과했습니다'
                        : '오늘 $dailyCount/3개 문의 작성',
                    style: TextStyle(
                      fontSize: 13,
                      color: isLimitReached
                          ? Colors.red.shade700
                          : Colors.grey.shade700,
                      fontWeight:
                          isLimitReached ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '문의하신 내용은 운영팀에서 검토 후 답변을 드립니다.\n답변은 \'문의 내역\'에서 확인하실 수 있습니다.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 에러 메시지
            if (formState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 20,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formState.error!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: (formState.isSubmitting || isLimitReached)
                  ? null
                  : () async {
                      setState(() => _showErrors = true);
                      final success =
                          await ref.read(questionFormProvider.notifier).submit();
                      if (success) {
                        // 목록에 추가
                        ref.read(questionListProvider.notifier).addQuestion(
                              formState.submittedQuestion!,
                            );
                      }
                    },
              child: formState.isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('문의 제출하기'),
            ),
          ),
        ),
      ),
    );
  }
}
