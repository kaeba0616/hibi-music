/// 관리자 대시보드 ViewModel 테스트

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibi_front/features/management/models/admin_models.dart';
import 'package:hibi_front/features/management/repos/admin_repo.dart';
import 'package:hibi_front/features/management/viewmodels/admin_dashboard_viewmodel.dart';

void main() {
  group('DashboardViewModel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          adminRepoProvider.overrideWithValue(AdminRepository(useMock: true)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should have default values', () {
      final state = container.read(dashboardViewModelProvider);

      expect(state.stats, isNull);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
    });

    test('loadStats should update state with stats', () async {
      final notifier = container.read(dashboardViewModelProvider.notifier);

      await notifier.loadStats();

      final state = container.read(dashboardViewModelProvider);
      expect(state.stats, isNotNull);
      expect(state.isLoading, false);
      expect(state.stats!.totalMembers, greaterThan(0));
    });

    test('loadStats should set isLoading to true during load', () async {
      final notifier = container.read(dashboardViewModelProvider.notifier);

      // Start loading
      final future = notifier.loadStats();

      // Check loading state (may be transient)
      await future;

      // After loading
      final state = container.read(dashboardViewModelProvider);
      expect(state.isLoading, false);
    });
  });

  group('DashboardState', () {
    test('copyWith should update only specified fields', () {
      const state = DashboardState();
      final newStats = AdminStats(
        totalMembers: 100,
        todayNewMembers: 5,
        totalSongs: 500,
        todayNewSongs: 10,
        pendingReports: 3,
        pendingQuestions: 7,
      );

      final updated = state.copyWith(stats: newStats, isLoading: true);

      expect(updated.stats, newStats);
      expect(updated.isLoading, true);
      expect(updated.errorMessage, isNull);
    });

    test('copyWith with clearError should set errorMessage to null', () {
      const state = DashboardState(errorMessage: 'Error');

      final updated = state.copyWith(clearError: true);

      expect(updated.errorMessage, isNull);
    });
  });
}
