/// F12 관리자 문의 관리 ViewModel

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../question/models/question_models.dart';
import '../models/admin_question_models.dart';
import '../repos/admin_repo.dart';

/// 문의 목록 상태
class QuestionListState {
  final List<AdminQuestionItem> questions;
  final int totalCount;
  final bool isLoading;
  final String? errorMessage;
  final QuestionStatus? selectedStatus;

  const QuestionListState({
    this.questions = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.errorMessage,
    this.selectedStatus,
  });

  QuestionListState copyWith({
    List<AdminQuestionItem>? questions,
    int? totalCount,
    bool? isLoading,
    String? errorMessage,
    QuestionStatus? selectedStatus,
    bool clearError = false,
    bool clearStatus = false,
  }) {
    return QuestionListState(
      questions: questions ?? this.questions,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
    );
  }
}

/// 문의 목록 ViewModel
class QuestionListViewModel extends StateNotifier<QuestionListState> {
  final AdminRepository _repository;

  QuestionListViewModel(this._repository) : super(const QuestionListState());

  /// 문의 목록 로드
  Future<void> loadQuestions({QuestionStatus? status}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedStatus: status,
      clearStatus: status == null,
    );

    try {
      final response = await _repository.getQuestions(status: status);
      state = state.copyWith(
        questions: response.questions,
        totalCount: response.totalCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '문의 목록을 불러오는데 실패했습니다',
      );
    }
  }

  /// 필터 변경
  void filterByStatus(QuestionStatus? status) {
    loadQuestions(status: status);
  }
}

/// 문의 상세/답변 상태
class QuestionDetailState {
  final AdminQuestionDetail? question;
  final bool isLoading;
  final bool isSubmitting;
  final String answer;
  final String? errorMessage;
  final bool isAnswered;

  const QuestionDetailState({
    this.question,
    this.isLoading = false,
    this.isSubmitting = false,
    this.answer = '',
    this.errorMessage,
    this.isAnswered = false,
  });

  QuestionDetailState copyWith({
    AdminQuestionDetail? question,
    bool? isLoading,
    bool? isSubmitting,
    String? answer,
    String? errorMessage,
    bool? isAnswered,
    bool clearError = false,
  }) {
    return QuestionDetailState(
      question: question ?? this.question,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      answer: answer ?? this.answer,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAnswered: isAnswered ?? this.isAnswered,
    );
  }
}

/// 문의 상세 ViewModel
class QuestionDetailViewModel extends StateNotifier<QuestionDetailState> {
  final AdminRepository _repository;
  final int questionId;

  QuestionDetailViewModel(this._repository, this.questionId)
      : super(const QuestionDetailState());

  /// 상세 로드
  Future<void> loadDetail() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final question = await _repository.getQuestionDetail(questionId);
      state = state.copyWith(
        question: question,
        answer: question.answer ?? '',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '문의 상세를 불러오는데 실패했습니다',
      );
    }
  }

  /// 답변 입력
  void updateAnswer(String answer) {
    state = state.copyWith(answer: answer);
  }

  /// 답변 제출
  Future<void> submitAnswer() async {
    final request = QuestionAnswerRequest(
      questionId: questionId,
      answer: state.answer,
    );

    final error = request.validate();
    if (error != null) {
      state = state.copyWith(errorMessage: error);
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _repository.answerQuestion(request);
      state = state.copyWith(
        isSubmitting: false,
        isAnswered: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: '답변 등록에 실패했습니다',
      );
    }
  }
}

/// 문의 목록 Provider
final questionListViewModelProvider =
    StateNotifierProvider<QuestionListViewModel, QuestionListState>((ref) {
  final repository = ref.watch(adminRepoProvider);
  return QuestionListViewModel(repository);
});

/// 문의 상세 Provider Family
final questionDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<QuestionDetailViewModel, QuestionDetailState, int>((ref, questionId) {
  final repository = ref.watch(adminRepoProvider);
  return QuestionDetailViewModel(repository, questionId);
});
