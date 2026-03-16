import 'package:flutter/material.dart';
import 'package:hidi/features/search/models/search_models.dart';

/// 사용자 검색 결과 타일
class UserSearchTile extends StatelessWidget {
  final SearchUser user;
  final VoidCallback onTap;
  final VoidCallback? onFollowTap;
  final bool isCurrentUser;

  const UserSearchTile({
    super.key,
    required this.user,
    required this.onTap,
    this.onFollowTap,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: user.profileImage != null
            ? NetworkImage(user.profileImage!)
            : null,
        child: user.profileImage == null
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(
        user.nickname,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('@${user.username}'),
      trailing: isCurrentUser
          ? null
          : _buildFollowButton(context),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildFollowButton(BuildContext context) {
    if (user.isFollowing) {
      return OutlinedButton(
        onPressed: onFollowTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(80, 32),
          visualDensity: VisualDensity.compact,
        ),
        child: const Text('팔로잉'),
      );
    } else {
      return FilledButton(
        onPressed: onFollowTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(80, 32),
          visualDensity: VisualDensity.compact,
        ),
        child: const Text('팔로우'),
      );
    }
  }
}
