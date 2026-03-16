import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/follow/viewmodels/follow_list_viewmodel.dart';
import 'package:hidi/features/follow/viewmodels/user_profile_viewmodel.dart';
import 'package:hidi/features/follow/widgets/follow_empty_view.dart';
import 'package:hidi/features/follow/widgets/unfollow_dialog.dart';
import 'package:hidi/features/follow/widgets/user_profile_header.dart';
import 'package:hidi/features/posts/widgets/post_card.dart';

/// 사용자 프로필 화면 (FO-01)
class UserProfileView extends ConsumerWidget {
  static const String routeName = 'user-profile';
  static const String routeURL = '/users/:userId';

  final int userId;

  const UserProfileView({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileViewModelProvider(userId));
    final viewModel = ref.read(userProfileViewModelProvider(userId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.profile?.nickname ?? ''),
        centerTitle: false,
        actions: [
          if (state.profile != null && !state.isCurrentUser(viewModel.currentUserId))
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showMoreMenu(context),
            ),
        ],
      ),
      body: _buildBody(context, ref, state, viewModel),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    UserProfileState state,
    UserProfileViewModel viewModel,
  ) {
    // 로딩 상태
    if (state.isLoading) {
      return const _LoadingView();
    }

    // 에러 상태
    if (state.error != null && state.profile == null) {
      return FollowErrorView(
        message: state.error,
        onRetry: () => viewModel.loadProfile(),
      );
    }

    final profile = state.profile;
    if (profile == null) {
      return const FollowErrorView(message: '사용자를 찾을 수 없습니다');
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: CustomScrollView(
        slivers: [
          // 프로필 헤더
          SliverToBoxAdapter(
            child: UserProfileHeader(
              profile: profile,
              isCurrentUser: state.isCurrentUser(viewModel.currentUserId),
              isFollowLoading: state.isFollowLoading,
              onFollowTap: () => _handleFollowTap(context, viewModel, state),
              onFollowersTap: () => context.push(
                '/users/$userId/follows?tab=followers',
              ),
              onFollowingTap: () => context.push(
                '/users/$userId/follows?tab=following',
              ),
              onEditProfileTap: () {
                // TODO: 프로필 수정 화면 이동
              },
            ),
          ),
          // 게시글 목록 또는 Empty View
          if (state.posts.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: UserPostsEmptyView(),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // 더 불러오기
                  if (index == state.posts.length) {
                    if (state.isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  final post = state.posts[index];
                  return PostCard(
                    post: post,
                    showAuthor: false, // 프로필 화면이므로 작성자 정보 숨김
                    onTap: () => context.push('/posts/${post.id}'),
                    onLikeTap: () {
                      // TODO: 좋아요 토글
                    },
                  );
                },
                childCount: state.posts.length + (state.hasMorePosts ? 1 : 0),
              ),
            ),
        ],
      ),
    );
  }

  void _handleFollowTap(
    BuildContext context,
    UserProfileViewModel viewModel,
    UserProfileState state,
  ) async {
    final profile = state.profile;
    if (profile == null) return;

    if (profile.isFollowing) {
      // 언팔로우 확인 다이얼로그
      final confirmed = await UnfollowDialog.show(context, profile.username);
      if (confirmed == true) {
        viewModel.toggleFollow();
      }
    } else {
      viewModel.toggleFollow();
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: const Text('신고', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 신고 기능
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 로딩 뷰
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const UserProfileHeaderSkeleton(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (_, __) => const PostCardSkeleton(),
          ),
        ],
      ),
    );
  }
}
