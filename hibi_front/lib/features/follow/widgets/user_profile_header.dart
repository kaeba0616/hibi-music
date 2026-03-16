import 'package:flutter/material.dart';
import 'package:hidi/features/follow/models/follow_models.dart';
import 'package:hidi/features/follow/widgets/follow_button.dart';

/// 사용자 프로필 헤더 컴포넌트
class UserProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final bool isCurrentUser;
  final bool isFollowLoading;
  final VoidCallback? onFollowTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onEditProfileTap;

  const UserProfileHeader({
    super.key,
    required this.profile,
    required this.isCurrentUser,
    this.isFollowLoading = false,
    this.onFollowTap,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onEditProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        // 프로필 이미지
        _buildProfileImage(),
        const SizedBox(height: 16),
        // 아이디
        Text(
          '@${profile.username}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        // 닉네임
        Text(
          profile.nickname,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        // 통계
        _buildStats(context),
        const SizedBox(height: 20),
        // 팔로우 버튼 또는 프로필 수정 버튼
        if (isCurrentUser)
          EditProfileButton(onTap: onEditProfileTap)
        else
          FollowButton(
            isFollowing: profile.isFollowing,
            isLoading: isFollowLoading,
            onTap: onFollowTap,
          ),
        const SizedBox(height: 24),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.grey.shade200,
      backgroundImage:
          profile.profileImage != null ? NetworkImage(profile.profileImage!) : null,
      child: profile.profileImage == null
          ? Icon(Icons.person, size: 40, color: Colors.grey.shade400)
          : null,
    );
  }

  Widget _buildStats(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatItem('게시글', profile.postCount, null),
        const SizedBox(width: 32),
        _buildStatItem('팔로워', profile.followerCount, onFollowersTap),
        const SizedBox(width: 32),
        _buildStatItem('팔로잉', profile.followingCount, onFollowingTap),
      ],
    );
  }

  Widget _buildStatItem(String label, int count, VoidCallback? onTap) {
    final content = Column(
      children: [
        Text(
          _formatCount(count),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: content,
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}만';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}천';
    }
    return count.toString();
  }
}

/// 프로필 헤더 스켈레톤
class UserProfileHeaderSkeleton extends StatelessWidget {
  const UserProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        // 프로필 이미지 스켈레톤
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(height: 16),
        // 아이디 스켈레톤
        Container(
          width: 80,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        // 닉네임 스켈레톤
        Container(
          width: 100,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 24),
        // 통계 스켈레톤
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 32,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        // 버튼 스켈레톤
        Container(
          width: 120,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(height: 1),
      ],
    );
  }
}
