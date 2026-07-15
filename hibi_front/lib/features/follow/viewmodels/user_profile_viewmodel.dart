import 'package:hidi/env.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/follow/mocks/follow_mock.dart';
import 'package:hidi/features/follow/models/follow_models.dart';
import 'package:hidi/features/follow/repos/follow_repo.dart';
import 'package:hidi/features/posts/models/post_models.dart';

/// 사용자 프로필 상태
class UserProfileState {
  final UserProfile? profile;
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isFollowLoading;
  final String? error;
  final int currentPage;
  final bool hasMorePosts;

  UserProfileState({
    this.profile,
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isFollowLoading = false,
    this.error,
    this.currentPage = 0,
    this.hasMorePosts = true,
  });

  UserProfileState copyWith({
    UserProfile? profile,
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isFollowLoading,
    String? error,
    int? currentPage,
    bool? hasMorePosts,
    bool clearError = false,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFollowLoading: isFollowLoading ?? this.isFollowLoading,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
    );
  }

  /// 본인 프로필인지 확인
  bool isCurrentUser(int currentUserId) => profile?.id == currentUserId;
}

/// 사용자 프로필 ViewModel
class UserProfileViewModel extends Notifier<UserProfileState> {
  UserProfileViewModel(this._userId);

  final int _userId;
  late final FollowRepository _repo;

  @override
  UserProfileState build() {
    _repo = ref.read(followRepoProvider);
    Future.microtask(() => loadProfile());
    return UserProfileState(isLoading: true);
  }

  /// 현재 로그인한 회원 ID (본인 콘텐츠 판별용).
  /// 미로그인 시 mock 모드에서만 mock ID, 실모드에서는 0(어떤 작성자와도 불일치).
  int get currentUserId =>
      ref.read(authRepo).user?.id ?? (Env.useMock ? mockCurrentUserId : 0);

  /// 프로필 로드
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final profile = await _repo.getUserProfile(_userId);
      if (profile == null) {
        state = state.copyWith(
          isLoading: false,
          error: '사용자를 찾을 수 없습니다',
        );
        return;
      }

      final posts = await _repo.getUserPosts(_userId);
      state = state.copyWith(
        profile: profile,
        posts: posts,
        isLoading: false,
        currentPage: 0,
        hasMorePosts: posts.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '프로필을 불러오는데 실패했습니다',
      );
    }
  }

  /// 게시글 더 불러오기
  Future<void> loadMorePosts() async {
    if (state.isLoadingMore || !state.hasMorePosts) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final newPosts = await _repo.getUserPosts(_userId, page: nextPage);

      state = state.copyWith(
        posts: [...state.posts, ...newPosts],
        currentPage: nextPage,
        hasMorePosts: newPosts.length >= 20,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadProfile();
  }

  /// 팔로우/언팔로우 토글
  Future<void> toggleFollow() async {
    final profile = state.profile;
    if (profile == null) return;

    // 낙관적 업데이트
    final wasFollowing = profile.isFollowing;
    state = state.copyWith(
      isFollowLoading: true,
      profile: profile.copyWith(
        isFollowing: !wasFollowing,
        followerCount: wasFollowing
            ? profile.followerCount - 1
            : profile.followerCount + 1,
      ),
    );

    try {
      final success = wasFollowing
          ? await _repo.unfollow(_userId)
          : await _repo.follow(_userId);

      if (!success) {
        // 실패 시 롤백
        state = state.copyWith(
          isFollowLoading: false,
          profile: profile,
          error: wasFollowing ? '언팔로우에 실패했습니다' : '팔로우에 실패했습니다',
        );
        return;
      }

      state = state.copyWith(isFollowLoading: false);
    } catch (e) {
      // 실패 시 롤백
      state = state.copyWith(
        isFollowLoading: false,
        profile: profile,
        error: '팔로우 처리에 실패했습니다',
      );
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// 사용자 프로필 ViewModel Provider
final userProfileViewModelProvider =
    NotifierProvider.family<UserProfileViewModel, UserProfileState, int>(
  UserProfileViewModel.new,
);
