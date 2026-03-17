/// F11 Report ViewModel
/// Riverpod StateNotifier를 사용한 신고 상태 관리

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/report_models.dart';
import '../repos/report_repo.dart';

/// 신고 폼 상태
class ReportFormState {
  final ReportTargetType targetType;
  final int targetId;
  final ReportReason? selectedReason;
  final String description;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final bool isDuplicate;

  const ReportFormState({
    required this.targetType,
    required this.targetId,
    this.selectedReason,
    this.description = '',
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.isDuplicate = false,
  });

  bool get canSubmit =>
      selectedReason != null && !isSubmitting && !isSuccess && !isDuplicate;

  bool get showDescriptionField => selectedReason == ReportReason.other;

  ReportFormState copyWith({
    ReportTargetType? targetType,
    int? targetId,
    ReportReason? selectedReason,
    String? description,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool? isDuplicate,
    bool clearSelectedReason = false,
    bool clearErrorMessage = false,
  }) {
    return ReportFormState(
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      selectedReason:
          clearSelectedReason ? null : (selectedReason ?? this.selectedReason),
      description: description ?? this.description,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isDuplicate: isDuplicate ?? this.isDuplicate,
    );
  }
}

/// 신고 폼 ViewModel
class ReportFormViewModel extends StateNotifier<ReportFormState> {
  final ReportRepository _repository;

  ReportFormViewModel(
    this._repository, {
    required ReportTargetType targetType,
    required int targetId,
  }) : super(ReportFormState(
          targetType: targetType,
          targetId: targetId,
        ));

  /// 신고 사유 선택
  void selectReason(ReportReason reason) {
    state = state.copyWith(
      selectedReason: reason,
      clearErrorMessage: true,
    );
  }

  /// 상세 내용 입력
  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// 신고 제출
  Future<void> submitReport() async {
    if (!state.canSubmit) return;

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);

    try {
      final request = ReportCreateRequest(
        targetType: state.targetType,
        targetId: state.targetId,
        reason: state.selectedReason!,
        description:
            state.showDescriptionField ? state.description : null,
      );

      final result = await _repository.createReport(request);

      if (result.success) {
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: true,
        );
      } else {
        if (result.errorCode == 'DUPLICATE_REPORT') {
          state = state.copyWith(
            isSubmitting: false,
            isDuplicate: true,
            errorMessage: result.message,
          );
        } else {
          state = state.copyWith(
            isSubmitting: false,
            errorMessage: result.message ?? '신고 처리 중 오류가 발생했습니다',
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: '네트워크 오류가 발생했습니다',
      );
    }
  }

  /// 상태 초기화
  void reset() {
    state = ReportFormState(
      targetType: state.targetType,
      targetId: state.targetId,
    );
  }
}

/// 신고 폼 ViewModel Provider Family
/// targetType과 targetId를 파라미터로 받아 Provider 생성
final reportFormViewModelProvider = StateNotifierProvider.autoDispose
    .family<ReportFormViewModel, ReportFormState, ({ReportTargetType targetType, int targetId})>(
  (ref, params) {
    final repository = ref.watch(reportRepoProvider);
    return ReportFormViewModel(
      repository,
      targetType: params.targetType,
      targetId: params.targetId,
    );
  },
);

/// 신고 대상 정보를 위한 helper
String getReportTargetDescription(ReportTargetType targetType) {
  switch (targetType) {
    case ReportTargetType.post:
      return '이 게시글을 신고하는 이유를 선택해주세요';
    case ReportTargetType.comment:
      return '이 댓글을 신고하는 이유를 선택해주세요';
    case ReportTargetType.member:
      return '이 사용자를 신고하는 이유를 선택해주세요';
  }
}
