/// RP-01: 신고 바텀시트 화면
/// 신고 사유 선택 및 제출

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report_models.dart';
import '../viewmodels/report_viewmodel.dart';
import '../widgets/report_reason_tile.dart';
import '../widgets/report_description_field.dart';
import '../widgets/report_submit_button.dart';
import '../widgets/report_success_dialog.dart';
import '../widgets/report_duplicate_dialog.dart';

class ReportBottomSheet extends ConsumerStatefulWidget {
  final ReportTargetType targetType;
  final int targetId;

  const ReportBottomSheet({
    super.key,
    required this.targetType,
    required this.targetId,
  });

  /// 바텀시트 표시
  static Future<bool> show(
    BuildContext context, {
    required ReportTargetType targetType,
    required int targetId,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportBottomSheet(
        targetType: targetType,
        targetId: targetId,
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends ConsumerState<ReportBottomSheet> {
  late final _providerKey = (
    targetType: widget.targetType,
    targetId: widget.targetId,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(reportFormViewModelProvider(_providerKey));
    final viewModel =
        ref.read(reportFormViewModelProvider(_providerKey).notifier);

    // 성공 시 다이얼로그 표시 후 닫기
    ref.listen(
      reportFormViewModelProvider(_providerKey),
      (previous, next) async {
        if (next.isSuccess && previous?.isSuccess != true) {
          await ReportSuccessDialog.show(context);
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        }
        if (next.isDuplicate && previous?.isDuplicate != true) {
          await ReportDuplicateDialog.show(context);
          if (mounted) {
            Navigator.of(context).pop(false);
          }
        }
      },
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 핸들
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // 제목
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.report_outlined,
                        color: theme.colorScheme.error,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '신고하기',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // 설명
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Text(
                    getReportTargetDescription(widget.targetType),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                // 구분선
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.dividerColor.withOpacity(0.5),
                ),
                // 신고 사유 목록
                ...ReportReason.values.map((reason) => ReportReasonTile(
                      reason: reason,
                      isSelected: state.selectedReason == reason,
                      enabled: !state.isSubmitting,
                      onTap: () => viewModel.selectReason(reason),
                    )),
                // "기타" 선택 시 상세 입력 필드
                if (state.showDescriptionField) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: ReportDescriptionField(
                      value: state.description,
                      onChanged: viewModel.updateDescription,
                      enabled: !state.isSubmitting,
                    ),
                  ),
                ],
                // 에러 메시지
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      state.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                // 제출 버튼
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ReportSubmitButton(
                    enabled: state.canSubmit,
                    isLoading: state.isSubmitting,
                    onPressed: viewModel.submitReport,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
