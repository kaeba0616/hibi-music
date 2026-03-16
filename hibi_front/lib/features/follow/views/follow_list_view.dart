import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/follow/models/follow_models.dart';
import 'package:hidi/features/follow/viewmodels/follow_list_viewmodel.dart';
import 'package:hidi/features/follow/widgets/follow_empty_view.dart';
import 'package:hidi/features/follow/widgets/follow_user_tile.dart';
import 'package:hidi/features/follow/widgets/unfollow_dialog.dart';

/// 팔로워/팔로잉 목록 화면 (FO-02)
class FollowListView extends ConsumerStatefulWidget {
  static const String routeName = 'follow-list';
  static const String routeURL = '/users/:userId/follows';

  final int userId;
  final FollowListTab initialTab;

  const FollowListView({
    super.key,
    required this.userId,
    this.initialTab = FollowListTab.followers,
  });

  @override
  ConsumerState<FollowListView> createState() => _FollowListViewState();
}

class _FollowListViewState extends ConsumerState<FollowListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == FollowListTab.followers ? 0 : 1,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final viewModel = ref.read(
          followListViewModelProvider(
            FollowListArg(userId: widget.userId, initialTab: widget.initialTab),
          ).notifier,
        );
        viewModel.changeTab(
          _tabController.index == 0
              ? FollowListTab.followers
              : FollowListTab.following,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arg = FollowListArg(userId: widget.userId, initialTab: widget.initialTab);
    final state = ref.watch(followListViewModelProvider(arg));
    final viewModel = ref.read(followListViewModelProvider(arg).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '팔로워 ${state.followerCount}'),
            Tab(text: '팔로잉 ${state.followingCount}'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowerList(context, state, viewModel),
          _buildFollowingList(context, state, viewModel),
        ],
      ),
    );
  }

  Widget _buildFollowerList(
    BuildContext context,
    FollowListState state,
    FollowListViewModel viewModel,
  ) {
    return _buildList(
      context: context,
      state: state,
      viewModel: viewModel,
      users: state.followers,
      isFollowers: true,
    );
  }

  Widget _buildFollowingList(
    BuildContext context,
    FollowListState state,
    FollowListViewModel viewModel,
  ) {
    return _buildList(
      context: context,
      state: state,
      viewModel: viewModel,
      users: state.following,
      isFollowers: false,
    );
  }

  Widget _buildList({
    required BuildContext context,
    required FollowListState state,
    required FollowListViewModel viewModel,
    required List<FollowUser> users,
    required bool isFollowers,
  }) {
    // 로딩 상태
    if (state.isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => const FollowUserTileSkeleton(),
      );
    }

    // 에러 상태
    if (state.error != null && users.isEmpty) {
      return FollowErrorView(
        message: state.error,
        onRetry: () => viewModel.loadList(),
      );
    }

    // Empty 상태
    if (users.isEmpty) {
      return FollowEmptyView(isFollowers: isFollowers);
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final isCurrentUser = user.id == viewModel.currentUserId;

          return FollowUserTile(
            user: user,
            isCurrentUser: isCurrentUser,
            isLoading: state.loadingFollowIds.contains(user.id),
            onTap: () => context.push('/users/${user.id}'),
            onFollowTap: () => _handleFollowTap(
              context,
              viewModel,
              user.id,
              user.username,
              user.isFollowing,
            ),
          );
        },
      ),
    );
  }

  void _handleFollowTap(
    BuildContext context,
    FollowListViewModel viewModel,
    int userId,
    String username,
    bool isFollowing,
  ) async {
    if (isFollowing) {
      // 언팔로우 확인 다이얼로그
      final confirmed = await UnfollowDialog.show(context, username);
      if (confirmed == true) {
        viewModel.toggleFollow(userId);
      }
    } else {
      viewModel.toggleFollow(userId);
    }
  }
}
