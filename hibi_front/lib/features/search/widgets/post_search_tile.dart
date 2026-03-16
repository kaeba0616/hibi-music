import 'package:flutter/material.dart';
import 'package:hidi/features/search/models/search_models.dart';
import 'package:hidi/utils/relative_time.dart';

/// 게시글 검색 결과 타일
class PostSearchTile extends StatelessWidget {
  final SearchPost post;
  final VoidCallback onTap;

  const PostSearchTile({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (post.authorProfileImage != null) ...[
                  CircleAvatar(
                    radius: 10,
                    backgroundImage: NetworkImage(post.authorProfileImage!),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  post.authorNickname,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  '·',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  relativeTime(post.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  '·',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.favorite_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 2),
                Text(
                  '${post.likeCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 2),
                Text(
                  '${post.commentCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
