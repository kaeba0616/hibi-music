import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/follow/models/follow_models.dart';
import 'package:hidi/features/follow/viewmodels/following_feed_viewmodel.dart';
import 'package:hidi/features/follow/widgets/follow_empty_view.dart';
import 'package:hidi/features/posts/viewmodels/post_list_viewmodel.dart';
import 'package:hidi/features/posts/widgets/post_card.dart';
import 'package:hidi/features/posts/widgets/post_empty_view.dart';

/// 게시글 목록 화면 (피드) - PO-01
class FeedView extends ConsumerStatefulWidget {
  static const String routeName = 'feed';
  static const String routeURL = '/feed';

  const FeedView({super.key});

  @override
  ConsumerState<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends ConsumerState<FeedView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final followingFeedVM = ref.read(followingFeedViewModelProvider.notifier);
      if (_tabController.index == 0) {
        followingFeedVM.changeFilter(FeedFilterType.all);
      } else {
        followingFeedVM.changeFilter(FeedFilterType.following);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('피드'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '팔로잉'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllFeedTab(),
          _FollowingFeedTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/posts/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 전체 피드 탭
class _AllFeedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postListViewModelProvider);
    final viewModel = ref.read(postListViewModelProvider.notifier);

    // 로딩 상태
    if (state.isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => const PostCardSkeleton(),
      );
    }

    // 에러 상태
    if (state.error != null) {
      return PostErrorView(
        message: state.error,
        onRetry: () => viewModel.loadPosts(),
      );
    }

    // Empty 상태
    if (state.posts.isEmpty) {
      return PostEmptyView(
        onCreateTap: () => context.push('/posts/create'),
      );
    }

    // 게시글 목록
    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 300) {
            viewModel.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // 로딩 인디케이터 (마지막 아이템)
            if (index == state.posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final post = state.posts[index];
            return PostCard(
              post: post,
              onTap: () => context.push('/posts/${post.id}'),
              onLikeTap: () => viewModel.toggleLike(post.id),
              onAuthorTap: () => context.push('/users/${post.author.id}'),
              onSongTagTap: post.taggedSong != null
                  ? () {
                      // TODO: 노래 상세 화면 이동
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }
}

/// 팔로잉 피드 탭
class _FollowingFeedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(followingFeedViewModelProvider);
    final viewModel = ref.read(followingFeedViewModelProvider.notifier);

    // 로딩 상태
    if (state.isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => const PostCardSkeleton(),
      );
    }

    // 에러 상태
    if (state.error != null) {
      return PostErrorView(
        message: state.error,
        onRetry: () => viewModel.loadFollowingFeed(),
      );
    }

    // Empty 상태
    if (state.isEmpty) {
      return FollowingFeedEmptyView(
        onSearchTap: () {
          // TODO: 검색 화면 이동 (F8 연동)
        },
      );
    }

    // 게시글 목록
    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 300) {
            viewModel.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // 로딩 인디케이터 (마지막 아이템)
            if (index == state.posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final post = state.posts[index];
            return PostCard(
              post: post,
              onTap: () => context.push('/posts/${post.id}'),
              onLikeTap: () {
                // TODO: 좋아요 토글
              },
              onAuthorTap: () => context.push('/users/${post.author.id}'),
              onSongTagTap: post.taggedSong != null
                  ? () {
                      // TODO: 노래 상세 화면 이동
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }
}
