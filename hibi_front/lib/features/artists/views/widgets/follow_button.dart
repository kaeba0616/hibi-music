import 'package:flutter/material.dart';

/// 팔로우 버튼 위젯 (AC-F3-3)
class FollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback? onTap;
  final bool isLoading;

  const FollowButton({
    super.key,
    required this.isFollowing,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return SizedBox(
        width: 100,
        height: 36,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (isFollowing) {
      return FilledButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.check, size: 18),
        label: const Text('팔로잉'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(100, 36),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add, size: 18),
      label: const Text('팔로우'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(100, 36),
      ),
    );
  }
}
