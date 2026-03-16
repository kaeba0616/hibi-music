import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/follow/models/follow_models.dart';
import 'package:hidi/features/follow/repos/follow_repo.dart';
import 'package:hidi/features/posts/models/post_models.dart';

/// 팔로잉 피드 상태
class FollowingFeedState {
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final FeedFilterType filterType;

  FollowingFeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
    this.filterType = FeedFilterType.all,
  });

  FollowingFeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    FeedFilterType? filterType,
    bool clearError = false,
  }) {
    return FollowingFeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      filterType: filterType ?? this.filterType,
    );
  }

  /// 게시글이 비어있는지 확인
  bool get isEmpty => posts.isEmpty;
}

/// 팔로잉 피드 ViewModel
class FollowingFeedViewModel extends Notifier<FollowingFeedState> {
  late final FollowRepository _repo;

  @override
  FollowingFeedState build() {
    _repo = ref.read(followRepoProvider);
    return FollowingFeedState();
  }

  /// 피드 필터 변경
  void changeFilter(FeedFilterType filterType) {
    if (state.filterType == filterType) return;

    state = state.copyWith(filterType: filterType);

    if (filterType == FeedFilterType.following) {
      loadFollowingFeed();
    }
  }

  /// 팔로잉 피드 로드
  Future<void> loadFollowingFeed() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final posts = await _repo.getFollowingFeed();
      state = state.copyWith(
        posts: posts,
        isLoading: false,
        currentPage: 0,
        hasMore: posts.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '피드를 불러오는데 실패했습니다',
      );
    }
  }

  /// 피드 더 불러오기
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final newPosts = await _repo.getFollowingFeed(page: nextPage);

      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        currentPage: nextPage,
        hasMore: newPosts.length >= 20,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    if (state.filterType == FeedFilterType.following) {
      await loadFollowingFeed();
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// 팔로잉 피드 ViewModel Provider
final followingFeedViewModelProvider =
    NotifierProvider<FollowingFeedViewModel, FollowingFeedState>(
  FollowingFeedViewModel.new,
);
