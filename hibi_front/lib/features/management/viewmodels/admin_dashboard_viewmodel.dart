/// F12 관리자 대시보드 ViewModel

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_models.dart';
import '../repos/admin_repo.dart';

/// 대시보드 상태
class DashboardState {
  final AdminStats? stats;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    this.stats,
    this.isLoading = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    AdminStats? stats,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 대시보드 ViewModel
class DashboardViewModel extends StateNotifier<DashboardState> {
  final AdminRepository _repository;

  DashboardViewModel(this._repository) : super(const DashboardState());

  /// 통계 로드
  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final stats = await _repository.getStats();
      state = state.copyWith(
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '통계를 불러오는데 실패했습니다',
      );
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadStats();
  }
}

/// 대시보드 ViewModel Provider
final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  final repository = ref.watch(adminRepoProvider);
  return DashboardViewModel(repository);
});
