import 'package:flutter/material.dart';
import 'package:hidi/features/posts/models/post_models.dart';
import 'package:hidi/features/posts/widgets/song_tag_card.dart';
import 'package:hidi/utils/relative_time.dart';

/// 게시글 카드 컴포넌트 (목록용)
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onSongTagTap;
  final VoidCallback? onCommentTap;
  final bool showAuthor;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLikeTap,
    this.onAuthorTap,
    this.onSongTagTap,
    this.onCommentTap,
    this.showAuthor = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 작성자 정보
            if (showAuthor) ...[
              _buildAuthorRow(context),
              const SizedBox(height: 12),
            ],

            // 본문
            _buildContent(context),

            // 이미지 (있는 경우)
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildImages(context),
            ],

            // 노래 태그 (있는 경우)
            if (post.taggedSong != null) ...[
              const SizedBox(height: 12),
              SongTagCard(
                song: post.taggedSong!,
                onTap: onSongTagTap,
                compact: true,
              ),
            ],

            // 좋아요/댓글 버튼
            const SizedBox(height: 12),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onAuthorTap,
      child: Row(
        children: [
          // 프로필 이미지
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.surfaceContainerHigh,
            backgroundImage: post.author.profileImage != null
                ? NetworkImage(post.author.profileImage!)
                : null,
            child: post.author.profileImage == null
                ? Icon(
                    Icons.person,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // 닉네임, 아이디, 시간
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.author.nickname,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '@${post.author.username} · ${formatRelativeTime(post.createdAt)}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Text(
      post.content,
      style: const TextStyle(fontSize: 15),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildImages(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (post.images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            post.images.first,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: colorScheme.surfaceContainerHigh,
              child: Icon(
                Icons.image,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    // 2개 이상일 경우 그리드 형태
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 150,
        child: Row(
          children: [
            for (int i = 0; i < post.images.length.clamp(0, 3); i++) ...[
              if (i > 0) const SizedBox(width: 2),
              Expanded(
                child: Image.network(
                  post.images[i],
                  fit: BoxFit.cover,
                  height: 150,
                  errorBuilder: (_, __, ___) => Container(
                    color: colorScheme.surfaceContainerHigh,
                    child: Icon(
                      Icons.image,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
            if (post.images.length > 3) ...[
              const SizedBox(width: 2),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      post.images[3],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colorScheme.surfaceContainerHigh,
                      ),
                    ),
                    Container(
                      color: Colors.black45,
                      alignment: Alignment.center,
                      child: Text(
                        '+${post.images.length - 3}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // 좋아요 버튼
        InkWell(
          onTap: onLikeTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: post.isLiked
                      ? Colors.red
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likeCount}',
                  style: TextStyle(
                    color: post.isLiked
                        ? Colors.red
                        : colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 댓글 버튼
        InkWell(
          onTap: onCommentTap ?? onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.commentCount}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 게시글 카드 로딩 스켈레톤
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 작성자 정보 스켈레톤
          Row(
            children: [
              _skeleton(context, width: 40, height: 40, circular: true),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeleton(context, width: 80, height: 14),
                  const SizedBox(height: 4),
                  _skeleton(context, width: 120, height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 본문 스켈레톤
          _skeleton(context, width: double.infinity, height: 14),
          const SizedBox(height: 6),
          _skeleton(context, width: 200, height: 14),
          const SizedBox(height: 12),
          // 액션 버튼 스켈레톤
          Row(
            children: [
              _skeleton(context, width: 50, height: 20),
              const SizedBox(width: 16),
              _skeleton(context, width: 50, height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _skeleton(
    BuildContext context, {
    required double width,
    required double height,
    bool circular = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(circular ? height / 2 : 4),
      ),
    );
  }
}
