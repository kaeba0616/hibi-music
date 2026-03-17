import 'package:flutter/material.dart';
import 'package:hidi/features/comments/models/comment_models.dart';
import 'package:hidi/utils/relative_time.dart';
import 'package:shimmer/shimmer.dart';

/// 댓글 카드 위젯 - CO-03, CO-04
class CommentCard extends StatelessWidget {
  final Comment comment;
  final bool isReply;
  final bool isOwnComment;
  final VoidCallback? onLikeTap;
  final VoidCallback? onReplyTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onMentionTap;
  final VoidCallback? onReportTap;

  const CommentCard({
    super.key,
    required this.comment,
    this.isReply = false,
    this.isOwnComment = false,
    this.onLikeTap,
    this.onReplyTap,
    this.onDeleteTap,
    this.onAuthorTap,
    this.onMentionTap,
    this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 삭제된 댓글
    if (comment.isDeleted) {
      return _buildDeletedComment(context, colorScheme);
    }

    // 필터링된 댓글 (F16: AC-F6-8)
    if (comment.isFiltered) {
      return _buildFilteredComment(context, colorScheme);
    }

    return Padding(
      padding: EdgeInsets.only(left: isReply ? 40 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 이미지
          GestureDetector(
            onTap: onAuthorTap,
            child: CircleAvatar(
              radius: isReply ? 14 : 18,
              backgroundColor: colorScheme.surfaceContainerHigh,
              backgroundImage: comment.author.profileImage != null
                  ? NetworkImage(comment.author.profileImage!)
                  : null,
              child: comment.author.profileImage == null
                  ? Icon(
                      Icons.person,
                      size: isReply ? 14 : 18,
                      color: colorScheme.onSurfaceVariant,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // 댓글 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더: 닉네임, 시간, 더보기 메뉴
                Row(
                  children: [
                    GestureDetector(
                      onTap: onAuthorTap,
                      child: Text(
                        comment.author.nickname,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: isReply ? 13 : 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· ${formatRelativeTime(comment.createdAt)}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: isReply ? 11 : 12,
                      ),
                    ),
                    const Spacer(),
                    // 더보기 메뉴: 본인 → 삭제, 타인 → 신고하기 (F16)
                    if (isOwnComment || onReportTap != null)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            onDeleteTap?.call();
                          } else if (value == 'report') {
                            onReportTap?.call();
                          }
                        },
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        icon: Icon(
                          Icons.more_vert,
                          color: colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                        itemBuilder: (context) => [
                          if (isOwnComment)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('삭제'),
                            ),
                          if (!isOwnComment && onReportTap != null)
                            const PopupMenuItem(
                              value: 'report',
                              child: Text('신고하기'),
                            ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // 댓글 본문
                _buildContent(context, colorScheme),
                const SizedBox(height: 8),
                // 액션: 좋아요, 답글
                Row(
                  children: [
                    // 좋아요 버튼
                    GestureDetector(
                      onTap: onLikeTap,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            comment.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: comment.isLiked
                                ? Colors.red
                                : colorScheme.onSurfaceVariant,
                          ),
                          if (comment.likeCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${comment.likeCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: comment.isLiked
                                    ? Colors.red
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // 대댓글이 아닌 경우에만 답글 버튼
                    if (!isReply && onReplyTap != null) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: onReplyTap,
                        child: Text(
                          '답글',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    // 대댓글인 경우 @멘션 하이라이트
    if (isReply && comment.parentAuthorNickname != null) {
      final mention = '@${comment.parentAuthorNickname}';
      final content = comment.content;

      if (content.startsWith(mention)) {
        return RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isReply ? 13 : 14,
              color: colorScheme.onSurface,
              height: 1.4,
            ),
            children: [
              WidgetSpan(
                child: GestureDetector(
                  onTap: onMentionTap,
                  child: Text(
                    mention,
                    style: TextStyle(
                      fontSize: isReply ? 13 : 14,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              TextSpan(text: content.substring(mention.length)),
            ],
          ),
        );
      }
    }

    return Text(
      comment.content,
      style: TextStyle(
        fontSize: isReply ? 13 : 14,
        height: 1.4,
      ),
    );
  }

  /// 필터링된 댓글 표시 (F16: AC-F6-8)
  Widget _buildFilteredComment(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(left: isReply ? 40 : 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '[부적절한 내용이 포함된 댓글입니다]',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeletedComment(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(left: isReply ? 40 : 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '삭제된 댓글입니다',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// 댓글 카드 스켈레톤
class CommentCardSkeleton extends StatelessWidget {
  final bool isReply;

  const CommentCardSkeleton({
    super.key,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: EdgeInsets.only(left: isReply ? 40 : 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 이미지 스켈레톤
            CircleAvatar(
              radius: isReply ? 14 : 18,
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 스켈레톤
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 내용 스켈레톤
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 200,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
