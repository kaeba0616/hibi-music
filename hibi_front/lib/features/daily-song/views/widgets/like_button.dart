import 'package:flutter/material.dart';

/// 좋아요 버튼 위젯 (애니메이션 포함)
class LikeButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;
  final double size;
  final int? likeCount;
  final bool showCount;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.size = 24.0,
    this.likeCount,
    this.showCount = false,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.showCount && widget.likeCount != null) {
      return InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Icon(
                  widget.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.isLiked ? Colors.red : colorScheme.onSurface,
                  size: widget.size,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _formatCount(widget.likeCount!),
                style: TextStyle(
                  fontSize: widget.size * 0.6,
                  fontWeight: FontWeight.w500,
                  color: widget.isLiked ? Colors.red : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return IconButton(
      onPressed: _handleTap,
      icon: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          widget.isLiked ? Icons.favorite : Icons.favorite_border,
          color: widget.isLiked ? Colors.red : colorScheme.onSurface,
          size: widget.size,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
