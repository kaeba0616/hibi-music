/// MG-04: 문의 목록 화면

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../question/models/question_models.dart';
import '../viewmodels/admin_question_viewmodel.dart';
import '../widgets/admin_question_tile.dart';
import '../widgets/filter_chip_bar.dart';

class AdminQuestionListView extends ConsumerStatefulWidget {
  const AdminQuestionListView({super.key});

  @override
  ConsumerState<AdminQuestionListView> createState() =>
      _AdminQuestionListViewState();
}

class _AdminQuestionListViewState extends ConsumerState<AdminQuestionListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(questionListViewModelProvider.notifier).loadQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionListViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('문의 관리'),
      ),
      body: Column(
        children: [
          // 필터 바
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FilterChipBar<QuestionStatus>(
              items: const [
                FilterChipItem(value: QuestionStatus.pending, label: '답변대기'),
                FilterChipItem(value: QuestionStatus.answered, label: '답변완료'),
              ],
              selectedValue: state.selectedStatus,
              onSelected: (status) {
                ref
                    .read(questionListViewModelProvider.notifier)
                    .filterByStatus(status);
              },
            ),
          ),
          const Divider(height: 1),
          // 문의 목록
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.errorMessage!),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () {
                                ref
                                    .read(questionListViewModelProvider.notifier)
                                    .loadQuestions();
                              },
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : state.questions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  size: 64,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '문의 내역이 없습니다',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(questionListViewModelProvider.notifier)
                                  .loadQuestions();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: state.questions.length,
                              itemBuilder: (context, index) {
                                final question = state.questions[index];
                                return AdminQuestionTile(
                                  question: question,
                                  onTap: () {
                                    context.push(
                                        '/admin/questions/${question.id}');
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
