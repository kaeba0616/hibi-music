/// MG-05: 문의 상세/답변 화면

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../question/models/question_models.dart';
import '../viewmodels/admin_question_viewmodel.dart';
import '../widgets/status_badge.dart';

class AdminQuestionDetailView extends ConsumerStatefulWidget {
  final int questionId;

  const AdminQuestionDetailView({
    super.key,
    required this.questionId,
  });

  @override
  ConsumerState<AdminQuestionDetailView> createState() =>
      _AdminQuestionDetailViewState();
}

class _AdminQuestionDetailViewState
    extends ConsumerState<AdminQuestionDetailView> {
  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(questionDetailViewModelProvider(widget.questionId).notifier)
          .loadDetail();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionDetailViewModelProvider(widget.questionId));
    final theme = Theme.of(context);

    // 답변 텍스트 동기화
    if (state.answer.isNotEmpty &&
        _answerController.text != state.answer) {
      _answerController.text = state.answer;
    }

    // 답변 완료 시 뒤로가기
    ref.listen(questionDetailViewModelProvider(widget.questionId), (prev, next) {
      if (next.isAnswered && prev?.isAnswered != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('답변이 등록되었습니다')),
        );
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('문의 상세'),
      ),
      body: state.isLoading
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
                              .read(questionDetailViewModelProvider(
                                      widget.questionId)
                                  .notifier)
                              .loadDetail();
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : state.question == null
                  ? const Center(child: Text('문의를 찾을 수 없습니다'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상태와 날짜
                          Row(
                            children: [
                              QuestionStatusBadge(status: state.question!.status),
                              const Spacer(),
                              Text(
                                _formatDate(state.question!.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 문의자 정보
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.question!.memberNickname,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    state.question!.memberEmail,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // 문의 제목
                          Text(
                            state.question!.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 문의 내용
                          Text(
                            state.question!.content,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 16),
                          // 답변 영역
                          Text(
                            '답변',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (state.question!.status == QuestionStatus.answered &&
                              state.question!.answer != null) ...[
                            // 기존 답변 표시
                            Card(
                              color: theme.colorScheme.primary.withOpacity(0.05),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.support_agent,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '관리자',
                                          style:
                                              theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (state.question!.answeredAt != null)
                                          Text(
                                            _formatDate(
                                                state.question!.answeredAt!),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      state.question!.answer!,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            // 답변 입력 필드
                            TextField(
                              controller: _answerController,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                hintText: '답변을 입력해주세요',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                ref
                                    .read(questionDetailViewModelProvider(
                                            widget.questionId)
                                        .notifier)
                                    .updateAnswer(value);
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: state.isSubmitting ||
                                        state.answer.trim().isEmpty
                                    ? null
                                    : () {
                                        ref
                                            .read(questionDetailViewModelProvider(
                                                    widget.questionId)
                                                .notifier)
                                            .submitAnswer();
                                      },
                                child: state.isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Text('답변 등록'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
