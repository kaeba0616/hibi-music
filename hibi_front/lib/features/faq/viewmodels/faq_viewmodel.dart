import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/faq_models.dart';
import '../repos/faq_repo.dart';

/// FAQ 화면 상태
class FAQState {
  final List<FAQ> faqs;
  final Map<FAQCategory, List<FAQ>> groupedFAQs;
  final FAQCategory selectedCategory;
  final String searchKeyword;
  final Set<int> expandedFAQIds;
  final bool isLoading;
  final String? errorMessage;

  const FAQState({
    this.faqs = const [],
    this.groupedFAQs = const {},
    this.selectedCategory = FAQCategory.all,
    this.searchKeyword = '',
    this.expandedFAQIds = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isEmpty => faqs.isEmpty;
  bool get hasError => errorMessage != null;
  bool get isSearching => searchKeyword.isNotEmpty;

  /// 현재 필터에 맞는 FAQ 목록
  List<FAQ> get filteredFAQs {
    return faqs.where((faq) {
      final matchesCategory = faq.matchesCategory(selectedCategory);
      final matchesKeyword = faq.matchesKeyword(searchKeyword);
      return matchesCategory && matchesKeyword;
    }).toList();
  }

  /// 현재 필터에 맞는 그룹화된 FAQ
  Map<FAQCategory, List<FAQ>> get filteredGroupedFAQs {
    if (selectedCategory != FAQCategory.all) {
      return {selectedCategory: filteredFAQs};
    }

    final Map<FAQCategory, List<FAQ>> grouped = {};
    for (final faq in filteredFAQs) {
      grouped.putIfAbsent(faq.category, () => []);
      grouped[faq.category]!.add(faq);
    }
    return grouped;
  }

  FAQState copyWith({
    List<FAQ>? faqs,
    Map<FAQCategory, List<FAQ>>? groupedFAQs,
    FAQCategory? selectedCategory,
    String? searchKeyword,
    Set<int>? expandedFAQIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FAQState(
      faqs: faqs ?? this.faqs,
      groupedFAQs: groupedFAQs ?? this.groupedFAQs,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      expandedFAQIds: expandedFAQIds ?? this.expandedFAQIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// FAQ ViewModel
class FAQViewModel extends StateNotifier<FAQState> {
  final FAQRepository _repository;
  Timer? _debounceTimer;

  FAQViewModel(this._repository) : super(const FAQState()) {
    loadFAQs();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// FAQ 목록 로드
  Future<void> loadFAQs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final faqs = await _repository.getFAQs();
      state = state.copyWith(
        faqs: faqs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'FAQ를 불러올 수 없습니다. 네트워크 연결을 확인해주세요.',
      );
    }
  }

  /// 카테고리 선택
  void selectCategory(FAQCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// 검색어 변경 (debounce 적용)
  void updateSearchKeyword(String keyword) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      state = state.copyWith(searchKeyword: keyword);
    });
  }

  /// 검색어 즉시 변경 (debounce 없이)
  void setSearchKeyword(String keyword) {
    _debounceTimer?.cancel();
    state = state.copyWith(searchKeyword: keyword);
  }

  /// 검색어 초기화
  void clearSearchKeyword() {
    _debounceTimer?.cancel();
    state = state.copyWith(searchKeyword: '');
  }

  /// FAQ 확장/축소 토글
  void toggleFAQExpansion(int faqId) {
    final newExpandedIds = Set<int>.from(state.expandedFAQIds);
    if (newExpandedIds.contains(faqId)) {
      newExpandedIds.remove(faqId);
    } else {
      newExpandedIds.add(faqId);
    }
    state = state.copyWith(expandedFAQIds: newExpandedIds);
  }

  /// FAQ 확장 여부 확인
  bool isFAQExpanded(int faqId) {
    return state.expandedFAQIds.contains(faqId);
  }

  /// 모든 FAQ 접기
  void collapseAllFAQs() {
    state = state.copyWith(expandedFAQIds: {});
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadFAQs();
  }
}

/// FAQ ViewModel Provider
final faqViewModelProvider =
    StateNotifierProvider<FAQViewModel, FAQState>((ref) {
  final repository = ref.watch(faqRepoProvider);
  return FAQViewModel(repository);
});
