import 'package:flutter/material.dart';
import 'package:hidi/features/follow/models/follow_models.dart';
import 'package:hidi/features/follow/widgets/follow_button.dart';

/// 팔로워/팔로잉 목록 아이템
class FollowUserTile extends StatelessWidget {
  final FollowUser user;
  final bool isCurrentUser;
  final bool isLoading;
  final VoidCallback? onTap;
  final VoidCallback? onFollowTap;

  const FollowUserTile({
    super.key,
    required this.user,
    this.isCurrentUser = false,
    this.isLoading = false,
    this.onTap,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 프로필 이미지
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  user.profileImage != null ? NetworkImage(user.profileImage!) : null,
              child: user.profileImage == null
                  ? Icon(Icons.person, size: 24, color: Colors.grey.shade400)
                  : null,
            ),
            const SizedBox(width: 12),
            // 사용자 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nickname,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // 팔로우 버튼 (본인이 아닐 때만)
            if (!isCurrentUser)
              FollowButton(
                isFollowing: user.isFollowing,
                isLoading: isLoading,
                onTap: onFollowTap,
                isCompact: true,
              ),
          ],
        ),
      ),
    );
  }
}

/// 팔로워/팔로잉 목록 아이템 스켈레톤
class FollowUserTileSkeleton extends StatelessWidget {
  const FollowUserTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 프로필 이미지 스켈레톤
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(width: 12),
          // 사용자 정보 스켈레톤
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          // 버튼 스켈레톤
          Container(
            width: 80,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}
