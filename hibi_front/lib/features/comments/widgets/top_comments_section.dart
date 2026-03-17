import 'package:flutter/material.dart';
import 'package:hidi/features/comments/models/comment_models.dart';
import 'package:hidi/features/comments/widgets/comment_card.dart';

/// 추천 Top3 댓글 섹션 위젯 - CE-01 (F16)
///
/// 좋아요 수 기준 상위 3개 댓글을 하이라이트하여 표시한다.
/// 좋아요 1개 이상인 댓글이 없으면 표시하지 않는다.
class TopCommentsSection extends StatelessWidget {
  final List<Comment> allComments;
  final int currentUserId;
  final void Function(int commentId)? onLikeTap;
  final void Function(Comment comment)? onReplyTap;
  final void Function(int commentId)? onDeleteTap;
  final void Function(int commentId)? onReportTap;

  const TopCommentsSection({
    super.key,
    required this.allComments,
    required this.currentUserId,
    this.onLikeTap,
    this.onReplyTap,
    this.onDeleteTap,
    this.onReportTap,
  });

  /// 모든 댓글(대댓글 포함)을 평탄화하여 좋아요 순으로 Top3 추출
  List<Comment> _getTopComments() {
    final List<Comment> flat = [];
    for (final comment in allComments) {
      if (!comment.isDeleted && !comment.isFiltered && comment.likeCount > 0) {
        flat.add(comment);
      }
      for (final reply in comment.replies) {
        if (!reply.isDeleted && !reply.isFiltered && reply.likeCount > 0) {
          flat.add(reply);
        }
      }
    }

    // 좋아요 내림차순, 동점 시 최신순
    flat.sort((a, b) {
      final likeDiff = b.likeCount.compareTo(a.likeCount);
      if (likeDiff != 0) return likeDiff;
      return b.createdAt.compareTo(a.createdAt);
    });

    return flat.take(3).toList();
  }

  /// 랭킹별 아이콘 색상
  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber; // 금
      case 1:
        return Colors.grey.shade400; // 은
      case 2:
        return Colors.brown.shade300; // 동
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topComments = _getTopComments();
    if (topComments.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          children: [
            Icon(
              Icons.emoji_events,
              size: 18,
              color: Colors.amber.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              '추천 댓글',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Top3 댓글 카드
        ...topComments.asMap().entries.map((entry) {
          final rank = entry.key;
          final comment = entry.value;
          final isOwn = comment.isAuthor(currentUserId);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 랭킹 아이콘
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 8),
                    child: Icon(
                      Icons.emoji_events,
                      size: 20,
                      color: _getRankColor(rank),
                    ),
                  ),
                  // 댓글 카드
                  Expanded(
                    child: CommentCard(
                      comment: comment,
                      isReply: false,
                      isOwnComment: isOwn,
                      onLikeTap: () => onLikeTap?.call(comment.id),
                      onReplyTap: comment.isReply
                          ? null
                          : () => onReplyTap?.call(comment),
                      onDeleteTap: isOwn
                          ? () => onDeleteTap?.call(comment.id)
                          : null,
                      onReportTap: !isOwn
                          ? () => onReportTap?.call(comment.id)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        // 구분선
        Divider(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          height: 24,
        ),
      ],
    );
  }
}
