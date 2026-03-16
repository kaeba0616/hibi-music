/// 더보기 메뉴 헬퍼
/// 신고하기 메뉴 아이템을 더보기 메뉴에 추가하기 위한 헬퍼 함수

import 'package:flutter/material.dart';

import '../models/report_models.dart';
import '../views/report_bottom_sheet.dart';

/// 신고하기 메뉴 아이템
class ReportMenuItem {
  /// 게시글 신고 메뉴 아이템 생성
  static Widget postMenuItem(
    BuildContext context, {
    required int postId,
    required bool isOwnPost,
    VoidCallback? onReported,
  }) {
    // 본인 게시글은 신고 메뉴 미표시 (AC-F11-8)
    if (isOwnPost) {
      return const SizedBox.shrink();
    }

    return _buildMenuItem(
      context,
      icon: Icons.report_outlined,
      label: '신고하기',
      onTap: () async {
        Navigator.of(context).pop(); // 메뉴 닫기
        final reported = await ReportBottomSheet.show(
          context,
          targetType: ReportTargetType.post,
          targetId: postId,
        );
        if (reported && onReported != null) {
          onReported();
        }
      },
    );
  }

  /// 댓글 신고 메뉴 아이템 생성
  static Widget commentMenuItem(
    BuildContext context, {
    required int commentId,
    required bool isOwnComment,
    VoidCallback? onReported,
  }) {
    // 본인 댓글은 신고 메뉴 미표시 (AC-F11-8)
    if (isOwnComment) {
      return const SizedBox.shrink();
    }

    return _buildMenuItem(
      context,
      icon: Icons.report_outlined,
      label: '신고하기',
      onTap: () async {
        Navigator.of(context).pop(); // 메뉴 닫기
        final reported = await ReportBottomSheet.show(
          context,
          targetType: ReportTargetType.comment,
          targetId: commentId,
        );
        if (reported && onReported != null) {
          onReported();
        }
      },
    );
  }

  /// 사용자 신고 메뉴 아이템 생성
  static Widget memberMenuItem(
    BuildContext context, {
    required int memberId,
    required bool isOwnProfile,
    VoidCallback? onReported,
  }) {
    // 본인은 신고 메뉴 미표시 (AC-F11-8)
    if (isOwnProfile) {
      return const SizedBox.shrink();
    }

    return _buildMenuItem(
      context,
      icon: Icons.report_outlined,
      label: '신고하기',
      onTap: () async {
        Navigator.of(context).pop(); // 메뉴 닫기
        final reported = await ReportBottomSheet.show(
          context,
          targetType: ReportTargetType.member,
          targetId: memberId,
        );
        if (reported && onReported != null) {
          onReported();
        }
      },
    );
  }

  /// 공통 메뉴 아이템 빌더
  static Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor ?? theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: iconColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 게시글 더보기 메뉴 바텀시트 (타인 게시글)
Future<void> showPostMoreMenu(
  BuildContext context, {
  required int postId,
  required bool isOwnPost,
  VoidCallback? onShare,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  VoidCallback? onReport,
  VoidCallback? onBlock,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final theme = Theme.of(context);

      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 본인 게시글: 수정, 삭제, 공유
              if (isOwnPost) ...[
                _MoreMenuItem(
                  icon: Icons.edit_outlined,
                  label: '수정하기',
                  onTap: () {
                    Navigator.of(context).pop();
                    onEdit?.call();
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.delete_outlined,
                  label: '삭제하기',
                  onTap: () {
                    Navigator.of(context).pop();
                    onDelete?.call();
                  },
                  iconColor: theme.colorScheme.error,
                ),
                _MoreMenuItem(
                  icon: Icons.share_outlined,
                  label: '공유하기',
                  onTap: () {
                    Navigator.of(context).pop();
                    onShare?.call();
                  },
                ),
              ] else ...[
                // 타인 게시글: 공유, 신고, 차단
                _MoreMenuItem(
                  icon: Icons.share_outlined,
                  label: '공유하기',
                  onTap: () {
                    Navigator.of(context).pop();
                    onShare?.call();
                  },
                ),
                ReportMenuItem.postMenuItem(
                  context,
                  postId: postId,
                  isOwnPost: isOwnPost,
                  onReported: onReport,
                ),
                _MoreMenuItem(
                  icon: Icons.block_outlined,
                  label: '이 사용자 차단',
                  onTap: () {
                    Navigator.of(context).pop();
                    onBlock?.call();
                  },
                ),
              ],
              // 취소 버튼
              const Divider(height: 1),
              _MoreMenuItem(
                icon: Icons.close,
                label: '취소',
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

/// 댓글 더보기 메뉴 바텀시트
Future<void> showCommentMoreMenu(
  BuildContext context, {
  required int commentId,
  required bool isOwnComment,
  VoidCallback? onReply,
  VoidCallback? onCopy,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  VoidCallback? onReport,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final theme = Theme.of(context);

      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 본인 댓글: 수정, 삭제
              if (isOwnComment) ...[
                _MoreMenuItem(
                  icon: Icons.edit_outlined,
                  label: '수정하기',
                  onTap: () {
                    Navigator.of(context).pop();
                    onEdit?.call();
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.delete_outlined,
                  label: '삭제하기',
                  onTap: () {
                    Navigator.of(context).pop();
                    onDelete?.call();
                  },
                  iconColor: theme.colorScheme.error,
                ),
              ] else ...[
                // 타인 댓글: 답글, 복사, 신고
                _MoreMenuItem(
                  icon: Icons.reply_outlined,
                  label: '답글 달기',
                  onTap: () {
                    Navigator.of(context).pop();
                    onReply?.call();
                  },
                ),
                _MoreMenuItem(
                  icon: Icons.copy_outlined,
                  label: '복사하기',
                  onTap: () {
                    Navigator.of(context).pop();
                    onCopy?.call();
                  },
                ),
                ReportMenuItem.commentMenuItem(
                  context,
                  commentId: commentId,
                  isOwnComment: isOwnComment,
                  onReported: onReport,
                ),
              ],
              // 취소 버튼
              const Divider(height: 1),
              _MoreMenuItem(
                icon: Icons.close,
                label: '취소',
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

/// 사용자 프로필 더보기 메뉴 바텀시트
Future<void> showProfileMoreMenu(
  BuildContext context, {
  required int memberId,
  required bool isOwnProfile,
  VoidCallback? onShare,
  VoidCallback? onReport,
  VoidCallback? onBlock,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final theme = Theme.of(context);

      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 공유
              _MoreMenuItem(
                icon: Icons.share_outlined,
                label: '프로필 공유',
                onTap: () {
                  Navigator.of(context).pop();
                  onShare?.call();
                },
              ),
              // 타인 프로필: 신고, 차단
              if (!isOwnProfile) ...[
                ReportMenuItem.memberMenuItem(
                  context,
                  memberId: memberId,
                  isOwnProfile: isOwnProfile,
                  onReported: onReport,
                ),
                _MoreMenuItem(
                  icon: Icons.block_outlined,
                  label: '이 사용자 차단',
                  onTap: () {
                    Navigator.of(context).pop();
                    onBlock?.call();
                  },
                ),
              ],
              // 취소 버튼
              const Divider(height: 1),
              _MoreMenuItem(
                icon: Icons.close,
                label: '취소',
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

/// 더보기 메뉴 아이템 위젯
class _MoreMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  const _MoreMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor ?? theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: iconColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
