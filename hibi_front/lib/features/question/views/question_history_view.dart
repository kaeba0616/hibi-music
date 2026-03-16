import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/question_viewmodel.dart';
import '../widgets/question_empty_view.dart';
import '../widgets/question_list_tile.dart';

/// QU-03: 문의 내역 화면
class QuestionHistoryView extends ConsumerStatefulWidget {
  const QuestionHistoryView({super.key});

  @override
  ConsumerState<QuestionHistoryView> createState() =>
      _QuestionHistoryViewState();
}

class _QuestionHistoryViewState extends ConsumerState<QuestionHistoryView> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 문의 목록 로드
    Future.microtask(() {
      ref.read(questionListProvider.notifier).loadQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('문의 내역'),
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/question/new');
        },
        icon: const Icon(Icons.add),
        label: const Text('새 문의'),
      ),
    );
  }

  Widget _buildBody(QuestionListState state) {
    // 로딩 상태
    if (state.isLoading && state.questions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러 상태
    if (state.error != null && state.questions.isEmpty) {
      return QuestionEmptyView(
        isError: true,
        message: state.error,
        onRetry: () {
          ref.read(questionListProvider.notifier).loadQuestions();
        },
      );
    }

    // Empty 상태
    if (state.questions.isEmpty) {
      return QuestionEmptyView(
        isError: false,
        onCreateQuestion: () {
          Navigator.pushNamed(context, '/question/new');
        },
      );
    }

    // 목록 표시
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(questionListProvider.notifier).loadQuestions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: state.questions.length,
        itemBuilder: (context, index) {
          final question = state.questions[index];
          return QuestionListTile(
            question: question,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/question/${question.id}',
                arguments: question.id,
              );
            },
          );
        },
      ),
    );
  }
}
