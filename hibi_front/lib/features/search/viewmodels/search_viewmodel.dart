import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/search/models/search_models.dart';
import 'package:hidi/features/search/repos/search_repo.dart';

/// 검색 상태
class SearchState {
  final String query;
  final SearchCategory selectedCategory;
  final SearchResult? result;
  final bool isLoading;
  final String? error;
  final List<RecentSearch> recentSearches;
  final List<String> popularKeywords;

  SearchState({
    this.query = '',
    this.selectedCategory = SearchCategory.all,
    this.result,
    this.isLoading = false,
    this.error,
    this.recentSearches = const [],
    this.popularKeywords = const [],
  });

  SearchState copyWith({
    String? query,
    SearchCategory? selectedCategory,
    SearchResult? result,
    bool? isLoading,
    String? error,
    List<RecentSearch>? recentSearches,
    List<String>? popularKeywords,
  }) {
    return SearchState(
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      recentSearches: recentSearches ?? this.recentSearches,
      popularKeywords: popularKeywords ?? this.popularKeywords,
    );
  }

  /// 검색 결과가 있는지
  bool get hasResult => result != null && query.isNotEmpty;

  /// 검색 결과가 비어있는지
  bool get isEmpty => hasResult && result!.isEmpty;
}

/// 검색 ViewModel
class SearchViewModel extends StateNotifier<SearchState> {
  final SearchRepository _repo;
  Timer? _debounceTimer;

  SearchViewModel(this._repo) : super(SearchState()) {
    _init();
  }

  Future<void> _init() async {
    await loadRecentSearches();
    await loadPopularKeywords();
  }

  /// 최근 검색어 로드
  Future<void> loadRecentSearches() async {
    try {
      final recentSearches = await _repo.getRecentSearches();
      state = state.copyWith(recentSearches: recentSearches);
    } catch (e) {
      // 에러 무시 (선택적 기능)
    }
  }

  /// 인기 검색어 로드
  Future<void> loadPopularKeywords() async {
    try {
      final keywords = await _repo.getPopularKeywords();
      state = state.copyWith(popularKeywords: keywords);
    } catch (e) {
      // 에러 무시 (선택적 기능)
    }
  }

  /// 검색어 변경 (디바운스 적용)
  void onQueryChanged(String query) {
    state = state.copyWith(query: query);

    // 기존 타이머 취소
    _debounceTimer?.cancel();

    // 2글자 미만이면 결과 초기화
    if (query.length < 2) {
      state = state.copyWith(result: null, isLoading: false);
      return;
    }

    // 300ms 디바운스
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  /// 검색 실행 (즉시)
  Future<void> search(String query) async {
    if (query.length < 2) return;

    state = state.copyWith(query: query);

    // 최근 검색어에 추가
    await _repo.addRecentSearch(query);
    await loadRecentSearches();

    await _performSearch(query);
  }

  /// 검색 수행
  Future<void> _performSearch(String query) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repo.search(query);
      state = state.copyWith(result: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: '검색 중 오류가 발생했습니다',
        isLoading: false,
      );
    }
  }

  /// 카테고리 변경
  void selectCategory(SearchCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// 검색어 클리어
  void clearQuery() {
    _debounceTimer?.cancel();
    state = state.copyWith(query: '', result: null, isLoading: false);
  }

  /// 최근 검색어 삭제
  Future<void> deleteRecentSearch(String query) async {
    await _repo.deleteRecentSearch(query);
    await loadRecentSearches();
  }

  /// 최근 검색어 전체 삭제
  Future<void> clearAllRecentSearches() async {
    await _repo.clearAllRecentSearches();
    await loadRecentSearches();
  }

  /// 아티스트 팔로우 토글
  Future<void> toggleArtistFollow(int artistId) async {
    if (state.result == null) return;

    // 낙관적 업데이트
    final updatedArtists = state.result!.artists.map((a) {
      if (a.id == artistId) {
        return a.copyWith(
          isFollowing: !a.isFollowing,
          followerCount: a.isFollowing
              ? a.followerCount - 1
              : a.followerCount + 1,
        );
      }
      return a;
    }).toList();

    state = state.copyWith(
      result: SearchResult(
        songs: state.result!.songs,
        artists: updatedArtists,
        posts: state.result!.posts,
        users: state.result!.users,
        totalSongs: state.result!.totalSongs,
        totalArtists: state.result!.totalArtists,
        totalPosts: state.result!.totalPosts,
        totalUsers: state.result!.totalUsers,
      ),
    );

    try {
      await _repo.toggleArtistFollow(artistId);
    } catch (e) {
      // 실패 시 롤백
      await _performSearch(state.query);
    }
  }

  /// 사용자 팔로우 토글
  Future<void> toggleUserFollow(int userId) async {
    if (state.result == null) return;

    // 낙관적 업데이트
    final updatedUsers = state.result!.users.map((u) {
      if (u.id == userId) {
        return u.copyWith(isFollowing: !u.isFollowing);
      }
      return u;
    }).toList();

    state = state.copyWith(
      result: SearchResult(
        songs: state.result!.songs,
        artists: state.result!.artists,
        posts: state.result!.posts,
        users: updatedUsers,
        totalSongs: state.result!.totalSongs,
        totalArtists: state.result!.totalArtists,
        totalPosts: state.result!.totalPosts,
        totalUsers: state.result!.totalUsers,
      ),
    );

    try {
      await _repo.toggleUserFollow(userId);
    } catch (e) {
      // 실패 시 롤백
      await _performSearch(state.query);
    }
  }

  /// 재시도
  Future<void> retry() async {
    if (state.query.isNotEmpty) {
      await _performSearch(state.query);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// SearchViewModel Provider
final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  final repo = ref.watch(searchRepoProvider);
  return SearchViewModel(repo);
});
