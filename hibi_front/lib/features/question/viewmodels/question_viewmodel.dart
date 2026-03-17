import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question_models.dart';
import '../repos/question_repo.dart';

/// 문의 목록 상태
class QuestionListState {
  final List<Question> questions;
  final bool isLoading;
  final String? error;

  const QuestionListState({
    this.questions = const [],
    this.isLoading = false,
    this.error,
  });

  QuestionListState copyWith({
    List<Question>? questions,
    bool? isLoading,
    String? error,
  }) {
    return QuestionListState(
      questions: questions ?? this.questions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 문의 목록 ViewModel
class QuestionListViewModel extends StateNotifier<QuestionListState> {
  final QuestionRepository _repository;

  QuestionListViewModel(this._repository) : super(const QuestionListState());

  /// 문의 목록 로드
  Future<void> loadQuestions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.getMyQuestions();
      state = state.copyWith(
        questions: response.questions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '문의 목록을 불러올 수 없습니다',
      );
    }
  }

  /// 새 문의 추가 (목록에 반영)
  void addQuestion(Question question) {
    state = state.copyWith(
      questions: [question, ...state.questions],
    );
  }
}

/// 문의 목록 Provider
final questionListProvider =
    StateNotifierProvider<QuestionListViewModel, QuestionListState>((ref) {
  final repository = ref.watch(questionRepoProvider);
  return QuestionListViewModel(repository);
});

/// 문의 상세 상태
class QuestionDetailState {
  final Question? question;
  final bool isLoading;
  final String? error;

  const QuestionDetailState({
    this.question,
    this.isLoading = false,
    this.error,
  });

  QuestionDetailState copyWith({
    Question? question,
    bool? isLoading,
    String? error,
  }) {
    return QuestionDetailState(
      question: question ?? this.question,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 문의 상세 ViewModel
class QuestionDetailViewModel extends StateNotifier<QuestionDetailState> {
  final QuestionRepository _repository;

  QuestionDetailViewModel(this._repository)
      : super(const QuestionDetailState());

  /// 문의 상세 로드
  Future<void> loadQuestion(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final question = await _repository.getQuestionById(id);
      if (question != null) {
        state = state.copyWith(
          question: question,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '문의를 찾을 수 없습니다',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '문의를 불러올 수 없습니다',
      );
    }
  }
}

/// 문의 상세 Provider (ID 기반)
final questionDetailProvider = StateNotifierProvider.family<
    QuestionDetailViewModel, QuestionDetailState, int>((ref, id) {
  final repository = ref.watch(questionRepoProvider);
  return QuestionDetailViewModel(repository);
});

/// 문의 작성 상태
class QuestionFormState {
  final QuestionType? selectedType;
  final String title;
  final String content;
  final bool isSubmitting;
  final String? error;
  final Question? submittedQuestion;

  const QuestionFormState({
    this.selectedType,
    this.title = '',
    this.content = '',
    this.isSubmitting = false,
    this.error,
    this.submittedQuestion,
  });

  QuestionFormState copyWith({
    QuestionType? selectedType,
    String? title,
    String? content,
    bool? isSubmitting,
    String? error,
    Question? submittedQuestion,
  }) {
    return QuestionFormState(
      selectedType: selectedType ?? this.selectedType,
      title: title ?? this.title,
      content: content ?? this.content,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      submittedQuestion: submittedQuestion,
    );
  }

  /// 폼 유효성 검사
  bool get isValid =>
      selectedType != null &&
      title.isNotEmpty &&
      title.length <= 100 &&
      content.length >= 10 &&
      content.length <= 1000;

  /// 개별 필드 에러 메시지
  String? get typeError => selectedType == null ? '문의 유형을 선택해주세요' : null;

  String? get titleError {
    if (title.isEmpty) return '제목을 입력해주세요';
    if (title.length > 100) return '제목은 100자 이내로 입력해주세요';
    return null;
  }

  String? get contentError {
    if (content.isEmpty) return '내용을 입력해주세요';
    if (content.length < 10) return '내용은 최소 10자 이상 입력해주세요';
    if (content.length > 1000) return '내용은 1000자 이내로 입력해주세요';
    return null;
  }
}

/// 문의 작성 ViewModel
class QuestionFormViewModel extends StateNotifier<QuestionFormState> {
  final QuestionRepository _repository;

  QuestionFormViewModel(this._repository) : super(const QuestionFormState());

  /// 유형 선택
  void setType(QuestionType type) {
    state = state.copyWith(selectedType: type, error: null);
  }

  /// 제목 입력
  void setTitle(String title) {
    state = state.copyWith(title: title, error: null);
  }

  /// 내용 입력
  void setContent(String content) {
    state = state.copyWith(content: content, error: null);
  }

  /// 폼 초기화
  void reset() {
    state = const QuestionFormState();
  }

  /// 문의 제출
  Future<bool> submit() async {
    // 유효성 검사
    if (state.selectedType == null) {
      state = state.copyWith(error: '문의 유형을 선택해주세요');
      return false;
    }
    if (state.title.isEmpty) {
      state = state.copyWith(error: '제목을 입력해주세요');
      return false;
    }
    if (state.content.length < 10) {
      state = state.copyWith(error: '내용은 최소 10자 이상 입력해주세요');
      return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final request = QuestionCreateRequest(
        type: state.selectedType!,
        title: state.title,
        content: state.content,
      );

      final question = await _repository.createQuestion(request);
      state = state.copyWith(
        isSubmitting: false,
        submittedQuestion: question,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}

/// 문의 작성 Provider
final questionFormProvider =
    StateNotifierProvider<QuestionFormViewModel, QuestionFormState>((ref) {
  final repository = ref.watch(questionRepoProvider);
  return QuestionFormViewModel(repository);
});

/// 오늘의 문의 작성 수 ViewModel (F17)
class QuestionDailyCountViewModel extends StateNotifier<int> {
  final QuestionRepository _repository;

  QuestionDailyCountViewModel(this._repository) : super(0);

  /// 오늘의 문의 작성 수 로드
  Future<void> loadTodayCount() async {
    try {
      final count = await _repository.getTodayQuestionCount();
      state = count;
    } catch (e) {
      // 실패 시 0 유지
    }
  }

  /// 문의 작성 후 카운트 증가
  void increment() {
    state = state + 1;
  }
}

/// 오늘의 문의 작성 수 Provider (F17)
final questionDailyCountProvider =
    StateNotifierProvider<QuestionDailyCountViewModel, int>((ref) {
  final repository = ref.watch(questionRepoProvider);
  return QuestionDailyCountViewModel(repository);
});
