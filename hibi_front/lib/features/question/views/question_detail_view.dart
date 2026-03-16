import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/question_models.dart';
import '../viewmodels/question_viewmodel.dart';
import '../widgets/question_answer_card.dart';
import '../widgets/question_status_badge.dart';

/// QU-04: 문의 상세 화면
class QuestionDetailView extends ConsumerStatefulWidget {
  final int questionId;

  const QuestionDetailView({
    super.key,
    required this.questionId,
  });

  @override
  ConsumerState<QuestionDetailView> createState() => _QuestionDetailViewState();
}

class _QuestionDetailViewState extends ConsumerState<QuestionDetailView> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 문의 상세 로드
    Future.microtask(() {
      ref
          .read(questionDetailProvider(widget.questionId).notifier)
          .loadQuestion(widget.questionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionDetailProvider(widget.questionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('문의 상세'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(QuestionDetailState state) {
    // 로딩 상태
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러 상태
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(questionDetailProvider(widget.questionId).notifier)
                    .loadQuestion(widget.questionId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final question = state.question;
    if (question == null) {
      return const Center(
        child: Text('문의를 찾을 수 없습니다'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 유형 + 상태 + 날짜
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _getTypeIcon(question.type),
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  question.type.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                QuestionStatusBadge(status: question.status),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              DateFormat('yyyy.MM.dd HH:mm').format(question.createdAt),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // 제목
          Text(
            question.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          // 내용
          Text(
            question.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // 답변 카드
          QuestionAnswerCard(question: question),
        ],
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
