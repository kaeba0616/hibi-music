/// MG-09: 회원 상세 화면

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/admin_models.dart';
import '../viewmodels/admin_member_viewmodel.dart';
import '../widgets/action_dialog.dart';
import '../widgets/status_badge.dart';

class AdminMemberDetailView extends ConsumerStatefulWidget {
  final int memberId;

  const AdminMemberDetailView({
    super.key,
    required this.memberId,
  });

  @override
  ConsumerState<AdminMemberDetailView> createState() =>
      _AdminMemberDetailViewState();
}

class _AdminMemberDetailViewState extends ConsumerState<AdminMemberDetailView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(memberDetailViewModelProvider(widget.memberId).notifier)
          .loadDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberDetailViewModelProvider(widget.memberId));
    final theme = Theme.of(context);

    // 제재 완료 시 뒤로가기
    ref.listen(memberDetailViewModelProvider(widget.memberId), (prev, next) {
      if (next.isSanctioned && prev?.isSanctioned != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원 제재가 완료되었습니다')),
        );
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 상세'),
        actions: [
          if (state.member != null &&
              state.member!.status == MemberStatus.active &&
              state.member!.role != MemberRole.admin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'suspend') {
                  _showSuspendDialog(context);
                } else if (value == 'ban') {
                  _showBanConfirmDialog(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'suspend',
                  child: Row(
                    children: [
                      Icon(Icons.block),
                      SizedBox(width: 8),
                      Text('일시 정지'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'ban',
                  child: Row(
                    children: [
                      Icon(Icons.person_off, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Text(
                        '강제 탈퇴',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.errorMessage!),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          ref
                              .read(memberDetailViewModelProvider(widget.memberId)
                                  .notifier)
                              .loadDetail();
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : state.member == null
                  ? const Center(child: Text('회원을 찾을 수 없습니다'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 프로필 헤더
                          Center(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 48,
                                  backgroundColor:
                                      theme.colorScheme.primary.withOpacity(0.1),
                                  backgroundImage:
                                      state.member!.profileImageUrl != null
                                          ? NetworkImage(
                                              state.member!.profileImageUrl!)
                                          : null,
                                  child: state.member!.profileImageUrl == null
                                      ? Icon(
                                          Icons.person,
                                          size: 48,
                                          color: theme.colorScheme.primary,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      state.member!.nickname,
                                      style:
                                          theme.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (state.member!.role == MemberRole.admin) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '관리자',
                                          style:
                                              theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                MemberStatusBadge(status: state.member!.status),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // 기본 정보
                          _buildSectionTitle(theme, '기본 정보'),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            theme,
                            [
                              _InfoItem(label: '이메일', value: state.member!.email),
                              _InfoItem(
                                  label: '가입일',
                                  value: _formatDate(state.member!.createdAt)),
                              if (state.member!.lastLoginAt != null)
                                _InfoItem(
                                    label: '마지막 로그인',
                                    value: _formatDate(state.member!.lastLoginAt!)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // 활동 통계
                          _buildSectionTitle(theme, '활동 통계'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  theme,
                                  '댓글',
                                  state.member!.commentCount.toString(),
                                  Icons.comment,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  theme,
                                  '좋아요',
                                  state.member!.likeCount.toString(),
                                  Icons.favorite,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  theme,
                                  '신고 횟수',
                                  state.member!.reportCount.toString(),
                                  Icons.flag,
                                  isWarning: state.member!.reportCount > 0,
                                ),
                              ),
                            ],
                          ),
                          if (state.member!.status == MemberStatus.suspended) ...[
                            const SizedBox(height: 24),
                            // 정지 정보
                            _buildSectionTitle(theme, '정지 정보'),
                            const SizedBox(height: 12),
                            _buildInfoCard(
                              theme,
                              [
                                if (state.member!.suspendedUntil != null)
                                  _InfoItem(
                                      label: '정지 해제일',
                                      value: _formatDate(
                                          state.member!.suspendedUntil!)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, List<_InfoItem> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            item.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.value,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon, {
    bool isWarning = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: isWarning
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isWarning ? theme.colorScheme.error : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showSuspendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SuspendDurationDialog(
        onSelect: (duration) {
          ref
              .read(memberDetailViewModelProvider(widget.memberId).notifier)
              .suspendMember(duration: duration);
        },
      ),
    );
  }

  void _showBanConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmActionDialog(
        title: '강제 탈퇴',
        message: '정말로 이 회원을 영구 퇴출하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
        confirmLabel: '강제 탈퇴',
        isDestructive: true,
        onConfirm: () {
          ref
              .read(memberDetailViewModelProvider(widget.memberId).notifier)
              .banMember();
        },
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});
}
