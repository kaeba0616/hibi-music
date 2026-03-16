import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/follow/mocks/follow_mock.dart';
import 'package:hidi/features/follow/models/follow_models.dart';
import 'package:hidi/features/follow/repos/follow_repo.dart';

/// 팔로워/팔로잉 목록 탭 타입
enum FollowListTab {
  followers,
  following,
}

/// 팔로워/팔로잉 목록 상태
class FollowListState {
  final List<FollowUser> followers;
  final List<FollowUser> following;
  final int followerCount;
  final int followingCount;
  final FollowListTab currentTab;
  final bool isLoading;
  final String? error;
  final Set<int> loadingFollowIds;

  FollowListState({
    this.followers = const [],
    this.following = const [],
    this.followerCount = 0,
    this.followingCount = 0,
    this.currentTab = FollowListTab.followers,
    this.isLoading = false,
    this.error,
    this.loadingFollowIds = const {},
  });

  FollowListState copyWith({
    List<FollowUser>? followers,
    List<FollowUser>? following,
    int? followerCount,
    int? followingCount,
    FollowListTab? currentTab,
    bool? isLoading,
    String? error,
    Set<int>? loadingFollowIds,
    bool clearError = false,
  }) {
    return FollowListState(
      followers: followers ?? this.followers,
      following: following ?? this.following,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      currentTab: currentTab ?? this.currentTab,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      loadingFollowIds: loadingFollowIds ?? this.loadingFollowIds,
    );
  }

  /// 현재 탭의 사용자 목록
  List<FollowUser> get currentList =>
      currentTab == FollowListTab.followers ? followers : following;

  /// 현재 목록이 비어있는지 확인
  bool get isEmpty => currentList.isEmpty;
}

/// 팔로워/팔로잉 목록 ViewModel 인자
class FollowListArg {
  final int userId;
  final FollowListTab initialTab;

  FollowListArg({
    required this.userId,
    this.initialTab = FollowListTab.followers,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FollowListArg &&
        other.userId == userId &&
        other.initialTab == initialTab;
  }

  @override
  int get hashCode => userId.hashCode ^ initialTab.hashCode;
}

/// 팔로워/팔로잉 목록 ViewModel
class FollowListViewModel extends FamilyNotifier<FollowListState, FollowListArg> {
  late final FollowRepository _repo;
  late final int _userId;

  @override
  FollowListState build(FollowListArg arg) {
    _repo = ref.read(followRepoProvider);
    _userId = arg.userId;
    Future.microtask(() => loadList());
    return FollowListState(
      currentTab: arg.initialTab,
      isLoading: true,
    );
  }

  /// 현재 사용자 ID (Mock용)
  int get currentUserId => mockCurrentUserId;

  /// 목록 로드
  Future<void> loadList() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final followersResponse = await _repo.getFollowers(_userId);
      final followingResponse = await _repo.getFollowing(_userId);

      state = state.copyWith(
        followers: followersResponse.users,
        following: followingResponse.users,
        followerCount: followersResponse.totalCount,
        followingCount: followingResponse.totalCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '목록을 불러오는데 실패했습니다',
      );
    }
  }

  /// 탭 변경
  void changeTab(FollowListTab tab) {
    state = state.copyWith(currentTab: tab);
  }

  /// 팔로우/언팔로우 토글
  Future<void> toggleFollow(int targetUserId) async {
    // 이미 로딩 중이면 무시
    if (state.loadingFollowIds.contains(targetUserId)) return;

    // 로딩 상태 추가
    state = state.copyWith(
      loadingFollowIds: {...state.loadingFollowIds, targetUserId},
    );

    // 해당 사용자의 현재 팔로우 상태 확인
    final userInFollowers = state.followers.firstWhere(
      (u) => u.id == targetUserId,
      orElse: () => FollowUser(id: 0, nickname: '', username: ''),
    );
    final userInFollowing = state.following.firstWhere(
      (u) => u.id == targetUserId,
      orElse: () => FollowUser(id: 0, nickname: '', username: ''),
    );

    final targetUser = userInFollowers.id != 0 ? userInFollowers : userInFollowing;
    if (targetUser.id == 0) {
      state = state.copyWith(
        loadingFollowIds: state.loadingFollowIds.difference({targetUserId}),
      );
      return;
    }

    final wasFollowing = targetUser.isFollowing;

    // 낙관적 업데이트
    state = state.copyWith(
      followers: _updateFollowStatus(state.followers, targetUserId, !wasFollowing),
      following: _updateFollowStatus(state.following, targetUserId, !wasFollowing),
    );

    try {
      final success = wasFollowing
          ? await _repo.unfollow(targetUserId)
          : await _repo.follow(targetUserId);

      if (!success) {
        // 실패 시 롤백
        state = state.copyWith(
          followers: _updateFollowStatus(state.followers, targetUserId, wasFollowing),
          following: _updateFollowStatus(state.following, targetUserId, wasFollowing),
          loadingFollowIds: state.loadingFollowIds.difference({targetUserId}),
          error: '팔로우 처리에 실패했습니다',
        );
        return;
      }

      state = state.copyWith(
        loadingFollowIds: state.loadingFollowIds.difference({targetUserId}),
      );
    } catch (e) {
      // 실패 시 롤백
      state = state.copyWith(
        followers: _updateFollowStatus(state.followers, targetUserId, wasFollowing),
        following: _updateFollowStatus(state.following, targetUserId, wasFollowing),
        loadingFollowIds: state.loadingFollowIds.difference({targetUserId}),
        error: '팔로우 처리에 실패했습니다',
      );
    }
  }

  /// 팔로우 상태 업데이트 헬퍼
  List<FollowUser> _updateFollowStatus(
    List<FollowUser> users,
    int userId,
    bool isFollowing,
  ) {
    return users.map((user) {
      if (user.id == userId) {
        return user.copyWith(isFollowing: isFollowing);
      }
      return user;
    }).toList();
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadList();
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// 팔로워/팔로잉 목록 ViewModel Provider
final followListViewModelProvider =
    NotifierProvider.family<FollowListViewModel, FollowListState, FollowListArg>(
  FollowListViewModel.new,
);
