/// MG-03: 신고 상세 화면

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../report/models/report_models.dart';
import '../models/admin_models.dart';
import '../models/admin_report_models.dart';
import '../viewmodels/admin_report_viewmodel.dart';
import '../widgets/action_dialog.dart';
import '../widgets/status_badge.dart';

class AdminReportDetailView extends ConsumerStatefulWidget {
  final int reportId;

  const AdminReportDetailView({
    super.key,
    required this.reportId,
  });

  @override
  ConsumerState<AdminReportDetailView> createState() =>
      _AdminReportDetailViewState();
}

class _AdminReportDetailViewState extends ConsumerState<AdminReportDetailView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(reportDetailViewModelProvider(widget.reportId).notifier)
          .loadDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportDetailViewModelProvider(widget.reportId));
    final theme = Theme.of(context);

    // 처리 완료 시 뒤로가기
    ref.listen(reportDetailViewModelProvider(widget.reportId), (prev, next) {
      if (next.isProcessed && prev?.isProcessed != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신고가 처리되었습니다')),
        );
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('신고 상세'),
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
                              .read(reportDetailViewModelProvider(widget.reportId)
                                  .notifier)
                              .loadDetail();
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : state.report == null
                  ? const Center(child: Text('신고를 찾을 수 없습니다'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상태
                          Row(
                            children: [
                              ReportStatusBadge(status: state.report!.status),
                              const Spacer(),
                              Text(
                                _formatDate(state.report!.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // 신고 정보
                          _buildSectionTitle(theme, '신고 정보'),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                              theme, '신고 유형', _getTargetTypeLabel(state.report!.targetType)),
                          _buildInfoRow(
                              theme, '신고 사유', _getReasonLabel(state.report!.reason)),
                          if (state.report!.description != null)
                            _buildInfoRow(
                                theme, '상세 내용', state.report!.description!),
                          const SizedBox(height: 24),
                          // 신고자 정보
                          _buildSectionTitle(theme, '신고자'),
                          const SizedBox(height: 12),
                          _buildInfoRow(theme, '닉네임', state.report!.reporterNickname),
                          _buildInfoRow(theme, '이메일', state.report!.reporterEmail),
                          const SizedBox(height: 24),
                          // 피신고자 정보
                          _buildSectionTitle(theme, '피신고자'),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                              theme, '닉네임', state.report!.targetMemberNickname),
                          _buildInfoRow(
                              theme, '이메일', state.report!.targetMemberEmail),
                          const SizedBox(height: 24),
                          // 신고 대상 콘텐츠
                          if (state.report!.targetContent != null) ...[
                            _buildSectionTitle(theme, '신고 대상 콘텐츠'),
                            const SizedBox(height: 12),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  state.report!.targetContent!.content,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
      bottomNavigationBar: state.report != null &&
              state.report!.status == ReportStatus.pending
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: state.isProcessing
                      ? null
                      : () => _showActionDialog(context),
                  child: state.isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('처리하기'),
                ),
              ),
            )
          : null,
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

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getTargetTypeLabel(ReportTargetType type) {
    switch (type) {
      case ReportTargetType.comment:
        return '댓글';
      case ReportTargetType.song:
        return '노래';
      case ReportTargetType.member:
        return '사용자';
    }
  }

  String _getReasonLabel(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return '스팸/광고';
      case ReportReason.abuse:
        return '욕설/비방';
      case ReportReason.inappropriate:
        return '부적절한 내용';
      case ReportReason.copyright:
        return '저작권 침해';
      case ReportReason.other:
        return '기타';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showActionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReportActionDialog(
        onDismiss: () {
          ref
              .read(reportDetailViewModelProvider(widget.reportId).notifier)
              .processReport(ReportAction.dismiss);
        },
        onWarn: () {
          ref
              .read(reportDetailViewModelProvider(widget.reportId).notifier)
              .processReport(ReportAction.warn);
        },
        onSuspend: () {
          _showSuspendDialog(context);
        },
        onBan: () {
          _showBanConfirmDialog(context);
        },
      ),
    );
  }

  void _showSuspendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SuspendDurationDialog(
        onSelect: (duration) {
          ref
              .read(reportDetailViewModelProvider(widget.reportId).notifier)
              .processReport(ReportAction.suspend, suspensionDuration: duration);
        },
      ),
    );
  }

  void _showBanConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmActionDialog(
        title: '강제 탈퇴',
        message: '정말로 이 사용자를 영구 퇴출하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
        confirmLabel: '강제 탈퇴',
        isDestructive: true,
        onConfirm: () {
          ref
              .read(reportDetailViewModelProvider(widget.reportId).notifier)
              .processReport(ReportAction.ban);
        },
      ),
    );
  }
}
