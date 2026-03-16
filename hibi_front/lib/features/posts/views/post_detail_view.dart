import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/comments/viewmodels/comment_viewmodel.dart';
import 'package:hidi/features/comments/widgets/comment_input.dart';
import 'package:hidi/features/comments/widgets/comment_section.dart';
import 'package:hidi/features/posts/models/post_models.dart';
import 'package:hidi/features/posts/viewmodels/post_list_viewmodel.dart';
import 'package:hidi/features/posts/viewmodels/post_viewmodel.dart';
import 'package:hidi/features/posts/widgets/post_empty_view.dart';
import 'package:hidi/features/posts/widgets/song_tag_card.dart';
import 'package:hidi/utils/relative_time.dart';

/// 게시글 상세 화면 - PO-03
class PostDetailView extends ConsumerStatefulWidget {
  static const String routeName = 'post-detail';
  static const String routeURL = '/posts/:postId';

  final int postId;

  const PostDetailView({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends ConsumerState<PostDetailView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postDetailViewModelProvider(widget.postId));
    final viewModel =
        ref.read(postDetailViewModelProvider(widget.postId).notifier);
    final commentState =
        ref.watch(commentSectionViewModelProvider(widget.postId));
    final commentViewModel =
        ref.read(commentSectionViewModelProvider(widget.postId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
        actions: [
          if (state.post != null)
            PopupMenuButton<String>(
              onSelected: (value) =>
                  _onMenuSelected(context, ref, value, state.post!),
              itemBuilder: (context) {
                if (viewModel.isOwnPost) {
                  return [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('수정'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('삭제'),
                    ),
                  ];
                } else {
                  return [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('신고'),
                    ),
                  ];
                }
              },
            ),
        ],
      ),
      body: _buildBody(context, ref, state, viewModel),
      // 댓글 입력창 (하단 고정)
      bottomNavigationBar: state.post != null
          ? CommentInput(
              replyTo: commentState.replyTo,
              isLoading: commentState.isSubmitting,
              onSubmit: (content) async {
                final success = await commentViewModel.submitComment(content);
                if (success && context.mounted) {
                  // 댓글 작성 후 스크롤을 하단으로
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                }
              },
              onCancelReply: () => commentViewModel.cancelReply(),
            )
          : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    PostDetailState state,
    PostDetailViewModel viewModel,
  ) {
    // 로딩 상태
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 에러 상태
    if (state.error != null) {
      return PostErrorView(
        message: state.error,
        onRetry: () => viewModel.loadPost(widget.postId),
      );
    }

    // 게시글 없음
    if (state.post == null) {
      return const PostErrorView(message: '게시글을 찾을 수 없습니다');
    }

    final post = state.post!;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 작성자 정보
          _buildAuthorSection(context, post),
          const SizedBox(height: 16),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),

          // 본문
          Text(
            post.content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),

          // 노래 태그
          if (post.taggedSong != null) ...[
            const SizedBox(height: 20),
            SongTagCard(
              song: post.taggedSong!,
              onTap: () {
                // TODO: 노래 상세 화면 이동
              },
            ),
          ],

          // 이미지
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildImages(context, post.images),
          ],

          // 액션 버튼 (좋아요, 댓글, 공유)
          const SizedBox(height: 20),
          _buildActions(context, ref, post),

          // 댓글 섹션
          const SizedBox(height: 20),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          CommentSection(
            postId: widget.postId,
            scrollController: _scrollController,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorSection(BuildContext context, Post post) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        // TODO: 프로필 화면 이동
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // 프로필 이미지
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.surfaceContainerHigh,
              backgroundImage: post.author.profileImage != null
                  ? NetworkImage(post.author.profileImage!)
                  : null,
              child: post.author.profileImage == null
                  ? Icon(
                      Icons.person,
                      color: colorScheme.onSurfaceVariant,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // 닉네임, 아이디, 시간
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.author.nickname,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '@${post.author.username}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatAbsoluteTime(post.createdAt),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImages(BuildContext context, List<String> images) {
    final colorScheme = Theme.of(context).colorScheme;

    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          images.first,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 200,
            color: colorScheme.surfaceContainerHigh,
            child: Icon(
              Icons.image,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    // 여러 이미지일 경우
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              images[index],
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 200,
                height: 200,
                color: colorScheme.surfaceContainerHigh,
                child: Icon(
                  Icons.image,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, Post post) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewModel =
        ref.read(postDetailViewModelProvider(widget.postId).notifier);
    final commentState =
        ref.watch(commentSectionViewModelProvider(widget.postId));

    return Row(
      children: [
        // 좋아요 버튼
        InkWell(
          onTap: () => viewModel.toggleLike(),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 24,
                  color:
                      post.isLiked ? Colors.red : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${post.likeCount}',
                  style: TextStyle(
                    color: post.isLiked
                        ? Colors.red
                        : colorScheme.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 댓글 버튼
        InkWell(
          onTap: () {
            // 댓글 섹션으로 스크롤
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 24,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${commentState.totalCount}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // 공유 버튼
        IconButton(
          onPressed: () {
            // TODO: 공유 기능
          },
          icon: Icon(
            Icons.share_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _onMenuSelected(
    BuildContext context,
    WidgetRef ref,
    String value,
    Post post,
  ) {
    switch (value) {
      case 'edit':
        context.push('/posts/${post.id}/edit');
        break;
      case 'delete':
        _showDeleteDialog(context, ref, post);
        break;
      case 'report':
        // TODO: 신고 화면 이동 (F11)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신고 기능은 곧 추가됩니다')),
        );
        break;
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Post post,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글을 삭제하시겠습니까?'),
        content: const Text('삭제된 게시글은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final viewModel =
          ref.read(postDetailViewModelProvider(widget.postId).notifier);
      final success = await viewModel.deletePost();

      if (success && context.mounted) {
        // 목록에서 제거
        ref.read(postListViewModelProvider.notifier).deletePost(post.id);
        context.pop();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글 삭제에 실패했습니다')),
        );
      }
    }
  }
}
