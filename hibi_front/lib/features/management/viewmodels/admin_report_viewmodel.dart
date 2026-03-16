/// F12 관리자 신고 관리 ViewModel

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../report/models/report_models.dart';
import '../models/admin_report_models.dart';
import '../repos/admin_repo.dart';

/// 신고 목록 상태
class ReportListState {
  final List<AdminReportItem> reports;
  final int totalCount;
  final bool isLoading;
  final String? errorMessage;
  final ReportStatus? selectedStatus;

  const ReportListState({
    this.reports = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.errorMessage,
    this.selectedStatus,
  });

  ReportListState copyWith({
    List<AdminReportItem>? reports,
    int? totalCount,
    bool? isLoading,
    String? errorMessage,
    ReportStatus? selectedStatus,
    bool clearError = false,
    bool clearStatus = false,
  }) {
    return ReportListState(
      reports: reports ?? this.reports,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
    );
  }
}

/// 신고 목록 ViewModel
class ReportListViewModel extends StateNotifier<ReportListState> {
  final AdminRepository _repository;

  ReportListViewModel(this._repository) : super(const ReportListState());

  /// 신고 목록 로드
  Future<void> loadReports({ReportStatus? status}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedStatus: status,
      clearStatus: status == null,
    );

    try {
      final response = await _repository.getReports(status: status);
      state = state.copyWith(
        reports: response.reports,
        totalCount: response.totalCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '신고 목록을 불러오는데 실패했습니다',
      );
    }
  }

  /// 필터 변경
  void filterByStatus(ReportStatus? status) {
    loadReports(status: status);
  }
}

/// 신고 상세 상태
class ReportDetailState {
  final AdminReportDetail? report;
  final bool isLoading;
  final bool isProcessing;
  final String? errorMessage;
  final bool isProcessed;

  const ReportDetailState({
    this.report,
    this.isLoading = false,
    this.isProcessing = false,
    this.errorMessage,
    this.isProcessed = false,
  });

  ReportDetailState copyWith({
    AdminReportDetail? report,
    bool? isLoading,
    bool? isProcessing,
    String? errorMessage,
    bool? isProcessed,
    bool clearError = false,
  }) {
    return ReportDetailState(
      report: report ?? this.report,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }
}

/// 신고 상세 ViewModel
class ReportDetailViewModel extends StateNotifier<ReportDetailState> {
  final AdminRepository _repository;
  final int reportId;

  ReportDetailViewModel(this._repository, this.reportId)
      : super(const ReportDetailState());

  /// 상세 로드
  Future<void> loadDetail() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final report = await _repository.getReportDetail(reportId);
      state = state.copyWith(
        report: report,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '신고 상세를 불러오는데 실패했습니다',
      );
    }
  }

  /// 신고 처리
  Future<void> processReport(ReportAction action, {String? note}) async {
    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      await _repository.processReport(
        ReportActionRequest(
          reportId: reportId,
          action: action,
          note: note,
        ),
      );
      state = state.copyWith(
        isProcessing: false,
        isProcessed: true,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: '신고 처리에 실패했습니다',
      );
    }
  }
}

/// 신고 목록 Provider
final reportListViewModelProvider =
    StateNotifierProvider<ReportListViewModel, ReportListState>((ref) {
  final repository = ref.watch(adminRepoProvider);
  return ReportListViewModel(repository);
});

/// 신고 상세 Provider Family
final reportDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<ReportDetailViewModel, ReportDetailState, int>((ref, reportId) {
  final repository = ref.watch(adminRepoProvider);
  return ReportDetailViewModel(repository, reportId);
});
