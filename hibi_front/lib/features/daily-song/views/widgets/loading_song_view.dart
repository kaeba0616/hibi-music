import 'package:flutter/material.dart';

/// 로딩 중일 때 표시하는 Shimmer 효과 위젯
class LoadingSongView extends StatefulWidget {
  const LoadingSongView({super.key});

  @override
  State<LoadingSongView> createState() => _LoadingSongViewState();
}

class _LoadingSongViewState extends State<LoadingSongView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 앨범 이미지 플레이스홀더
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return _buildShimmerBox(height: double.infinity);
                },
              ),
            ),
          ),

          // 텍스트 플레이스홀더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(width: 200, height: 24),
                const SizedBox(height: 8),
                _buildShimmerBox(width: 150, height: 20),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildShimmerCircle(28),
                    const SizedBox(width: 8),
                    _buildShimmerBox(width: 120, height: 18),
                  ],
                ),
                const SizedBox(height: 12),
                _buildShimmerBox(width: 180, height: 16),
                const SizedBox(height: 20),
                Center(child: _buildShimmerBox(width: 100, height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({double? width, double? height}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerCircle(double size) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }
}
