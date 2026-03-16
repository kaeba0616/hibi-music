import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/posts/models/post_models.dart';
import 'package:hidi/features/posts/mocks/post_mock.dart';
import 'package:hidi/features/posts/repos/post_repo.dart';

/// 게시글 목록 상태
class PostListState {
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;

  PostListState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
  });

  PostListState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return PostListState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// 게시글 목록 ViewModel (피드)
class PostListViewModel extends Notifier<PostListState> {
  @override
  PostListState build() {
    // 초기 로드
    Future.microtask(() => loadPosts());
    return PostListState(isLoading: true);
  }

  PostRepository get _repo => ref.read(postRepoProvider);

  /// 게시글 목록 로드 (첫 페이지)
  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final posts = await _repo.getPosts(page: 0);
      state = state.copyWith(
        posts: posts,
        isLoading: false,
        currentPage: 0,
        hasMore: posts.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '게시글을 불러올 수 없습니다',
      );
    }
  }

  /// 더 불러오기 (무한 스크롤)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final morePosts = await _repo.getPosts(page: nextPage);
      state = state.copyWith(
        posts: [...state.posts, ...morePosts],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: morePosts.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadPosts();
  }

  /// 좋아요 토글
  Future<void> toggleLike(int postId) async {
    // 낙관적 업데이트
    final updatedPosts = state.posts.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          isLiked: !post.isLiked,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }
      return post;
    }).toList();

    state = state.copyWith(posts: updatedPosts);

    // API 호출
    final success = await _repo.toggleLike(postId);

    if (!success) {
      // 실패 시 롤백
      await loadPosts();
    }
  }

  /// 게시글 삭제
  Future<bool> deletePost(int postId) async {
    final success = await _repo.deletePost(postId);

    if (success) {
      // 목록에서 제거
      final updatedPosts = state.posts.where((p) => p.id != postId).toList();
      state = state.copyWith(posts: updatedPosts);
    }

    return success;
  }

  /// 새 게시글 추가 (작성 후 호출)
  void addPost(Post post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }

  /// 게시글 업데이트 (수정 후 호출)
  void updatePost(Post post) {
    final updatedPosts = state.posts.map((p) {
      if (p.id == post.id) return post;
      return p;
    }).toList();
    state = state.copyWith(posts: updatedPosts);
  }

  /// 현재 사용자 ID (본인 게시글 확인용)
  int get currentUserId => mockCurrentUserId;
}

/// 게시글 목록 Provider
final postListViewModelProvider =
    NotifierProvider<PostListViewModel, PostListState>(
  () => PostListViewModel(),
);
