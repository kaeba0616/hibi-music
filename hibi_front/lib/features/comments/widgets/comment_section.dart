import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/comments/models/comment_models.dart';
import 'package:hidi/features/comments/viewmodels/comment_viewmodel.dart';
import 'package:hidi/features/comments/widgets/comment_card.dart';
import 'package:hidi/features/comments/widgets/comment_report_sheet.dart';
import 'package:hidi/features/comments/widgets/top_comments_section.dart';

/// 댓글 섹션 위젯 - CO-01
class CommentSection extends ConsumerWidget {
  final int postId;
  final ScrollController? scrollController;

  const CommentSection({
    super.key,
    required this.postId,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commentSectionViewModelProvider(postId));
    final viewModel = ref.read(commentSectionViewModelProvider(postId).notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        _buildHeader(context, colorScheme, state),
        const SizedBox(height: 16),
        // 댓글 목록
        _buildCommentList(context, ref, state, viewModel),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ColorScheme colorScheme,
    CommentSectionState state,
  ) {
    return Row(
      children: [
        Icon(
          Icons.chat_bubble_outline,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          state.totalCount > 0 ? '댓글 ${state.totalCount}개' : '댓글',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentList(
    BuildContext context,
    WidgetRef ref,
    CommentSectionState state,
    CommentSectionViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // 로딩 상태
    if (state.isLoading) {
      return Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CommentCardSkeleton(isReply: index == 1),
          ),
        ),
      );
    }

    // 에러 상태
    if (state.error != null && state.isEmpty) {
      return _buildErrorView(context, colorScheme, state.error!, viewModel);
    }

    // 빈 상태
    if (state.isEmpty) {
      return _buildEmptyView(context, colorScheme);
    }

    // 댓글 목록
    return Column(
      children: [
        // F16: Top3 추천 댓글 섹션 (AC-F6-6)
        TopCommentsSection(
          allComments: state.comments,
          currentUserId: viewModel.currentUserId,
          onLikeTap: (id) => viewModel.toggleLike(id),
          onReplyTap: (comment) => viewModel.startReply(comment),
          onDeleteTap: (id) => _showDeleteDialog(context, ref, id),
          onReportTap: (id) => _showReportSheet(context, ref, id),
        ),
        // 전체 댓글 목록
        ...state.comments.map((comment) {
          final isOwn = comment.isAuthor(viewModel.currentUserId);
          return Column(
            children: [
              // 원 댓글
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CommentCard(
                  comment: comment,
                  isReply: false,
                  isOwnComment: isOwn,
                  onLikeTap: comment.isDeleted || comment.isFiltered
                      ? null
                      : () => viewModel.toggleLike(comment.id),
                  onReplyTap: comment.isDeleted || comment.isFiltered
                      ? null
                      : () => viewModel.startReply(comment),
                  onDeleteTap: isOwn
                      ? () => _showDeleteDialog(context, ref, comment.id)
                      : null,
                  onReportTap: !isOwn && !comment.isDeleted && !comment.isFiltered
                      ? () => _showReportSheet(context, ref, comment.id)
                      : null,
                  onAuthorTap: () {
                    // TODO: 프로필 화면 이동
                  },
                ),
              ),
              // 대댓글
              ...comment.replies.map((reply) {
                final isReplyOwn = reply.isAuthor(viewModel.currentUserId);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CommentCard(
                    comment: reply,
                    isReply: true,
                    isOwnComment: isReplyOwn,
                    onLikeTap: reply.isFiltered
                        ? null
                        : () => viewModel.toggleLike(reply.id),
                    onDeleteTap: isReplyOwn
                        ? () => _showDeleteDialog(context, ref, reply.id)
                        : null,
                    onReportTap: !isReplyOwn && !reply.isDeleted && !reply.isFiltered
                        ? () => _showReportSheet(context, ref, reply.id)
                        : null,
                    onAuthorTap: () {
                      // TODO: 프로필 화면 이동
                    },
                    onMentionTap: () {
                      // TODO: 원 댓글로 스크롤
                    },
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildEmptyView(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 댓글이 없습니다',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '첫 번째 댓글을 남겨보세요!',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    ColorScheme colorScheme,
    String error,
    CommentSectionViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => viewModel.loadComments(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// F16: 댓글 신고 Bottom Sheet 표시 (AC-F6-7)
  void _showReportSheet(
    BuildContext context,
    WidgetRef ref,
    int commentId,
  ) {
    CommentReportSheet.show(
      context: context,
      commentId: commentId,
      onReport: (id, reason, description) async {
        final viewModel =
            ref.read(commentSectionViewModelProvider(postId).notifier);
        return viewModel.reportComment(id, reason, description);
      },
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    int commentId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글을 삭제하시겠습니까?'),
        content: const Text('삭제된 댓글은 복구할 수 없습니다.'),
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
          ref.read(commentSectionViewModelProvider(postId).notifier);
      final success = await viewModel.deleteComment(commentId);

      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글 삭제에 실패했습니다')),
        );
      }
    }
  }
}
