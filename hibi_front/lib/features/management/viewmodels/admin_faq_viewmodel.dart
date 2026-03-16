/// F12 관리자 FAQ 관리 ViewModel

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../faq/models/faq_models.dart';
import '../models/admin_faq_models.dart';
import '../repos/admin_repo.dart';

/// FAQ 목록 상태
class FAQListState {
  final List<AdminFAQItem> faqs;
  final int totalCount;
  final bool isLoading;
  final String? errorMessage;
  final FAQCategory? selectedCategory;

  const FAQListState({
    this.faqs = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory,
  });

  FAQListState copyWith({
    List<AdminFAQItem>? faqs,
    int? totalCount,
    bool? isLoading,
    String? errorMessage,
    FAQCategory? selectedCategory,
    bool clearError = false,
    bool clearCategory = false,
  }) {
    return FAQListState(
      faqs: faqs ?? this.faqs,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }
}

/// FAQ 목록 ViewModel
class FAQListViewModel extends StateNotifier<FAQListState> {
  final AdminRepository _repository;

  FAQListViewModel(this._repository) : super(const FAQListState());

  /// FAQ 목록 로드
  Future<void> loadFaqs({FAQCategory? category}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedCategory: category,
      clearCategory: category == null,
    );

    try {
      final response = await _repository.getFaqs(category: category);
      state = state.copyWith(
        faqs: response.faqs,
        totalCount: response.totalCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'FAQ 목록을 불러오는데 실패했습니다',
      );
    }
  }

  /// 카테고리 필터 변경
  void filterByCategory(FAQCategory? category) {
    loadFaqs(category: category);
  }

  /// FAQ 삭제
  Future<bool> deleteFaq(int id) async {
    try {
      await _repository.deleteFaq(id);
      // 목록에서 제거
      state = state.copyWith(
        faqs: state.faqs.where((f) => f.id != id).toList(),
        totalCount: state.totalCount - 1,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: 'FAQ 삭제에 실패했습니다');
      return false;
    }
  }
}

/// FAQ 편집 상태
class FAQEditState {
  final AdminFAQItem? originalFaq; // 수정 시 원본
  final FAQCategory category;
  final String question;
  final String answer;
  final int displayOrder;
  final bool isPublished;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSaved;

  const FAQEditState({
    this.originalFaq,
    this.category = FAQCategory.account,
    this.question = '',
    this.answer = '',
    this.displayOrder = 1,
    this.isPublished = true,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.isSaved = false,
  });

  bool get isCreate => originalFaq == null;
  bool get isUpdate => originalFaq != null;

  FAQEditState copyWith({
    AdminFAQItem? originalFaq,
    FAQCategory? category,
    String? question,
    String? answer,
    int? displayOrder,
    bool? isPublished,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSaved,
    bool clearError = false,
    bool clearOriginal = false,
  }) {
    return FAQEditState(
      originalFaq: clearOriginal ? null : (originalFaq ?? this.originalFaq),
      category: category ?? this.category,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      displayOrder: displayOrder ?? this.displayOrder,
      isPublished: isPublished ?? this.isPublished,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// FAQ 편집 ViewModel
class FAQEditViewModel extends StateNotifier<FAQEditState> {
  final AdminRepository _repository;
  final int? faqId;

  FAQEditViewModel(this._repository, this.faqId)
      : super(const FAQEditState());

  /// 수정 모드인 경우 기존 데이터 로드
  Future<void> loadFaq() async {
    if (faqId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _repository.getFaqs();
      final faq = response.faqs.firstWhere((f) => f.id == faqId);
      state = state.copyWith(
        originalFaq: faq,
        category: faq.category,
        question: faq.question,
        answer: faq.answer,
        displayOrder: faq.displayOrder,
        isPublished: faq.isPublished,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'FAQ를 불러오는데 실패했습니다',
      );
    }
  }

  void updateCategory(FAQCategory category) {
    state = state.copyWith(category: category);
  }

  void updateQuestion(String question) {
    state = state.copyWith(question: question);
  }

  void updateAnswer(String answer) {
    state = state.copyWith(answer: answer);
  }

  void updateDisplayOrder(int order) {
    state = state.copyWith(displayOrder: order);
  }

  void updateIsPublished(bool isPublished) {
    state = state.copyWith(isPublished: isPublished);
  }

  /// 저장
  Future<void> save() async {
    final request = FAQSaveRequest(
      id: faqId,
      category: state.category,
      question: state.question,
      answer: state.answer,
      displayOrder: state.displayOrder,
      isPublished: state.isPublished,
    );

    final error = request.validate();
    if (error != null) {
      state = state.copyWith(errorMessage: error);
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _repository.saveFaq(request);
      state = state.copyWith(
        isSubmitting: false,
        isSaved: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'FAQ 저장에 실패했습니다',
      );
    }
  }
}

/// FAQ 목록 Provider
final faqListViewModelProvider =
    StateNotifierProvider<FAQListViewModel, FAQListState>((ref) {
  final repository = ref.watch(adminRepoProvider);
  return FAQListViewModel(repository);
});

/// FAQ 편집 Provider Family (null이면 생성, id가 있으면 수정)
final faqEditViewModelProvider = StateNotifierProvider.autoDispose
    .family<FAQEditViewModel, FAQEditState, int?>((ref, faqId) {
  final repository = ref.watch(adminRepoProvider);
  return FAQEditViewModel(repository, faqId);
});
