/// MG-02: 신고 목록 화면

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../report/models/report_models.dart';
import '../viewmodels/admin_report_viewmodel.dart';
import '../widgets/admin_report_tile.dart';
import '../widgets/filter_chip_bar.dart';

class AdminReportListView extends ConsumerStatefulWidget {
  const AdminReportListView({super.key});

  @override
  ConsumerState<AdminReportListView> createState() =>
      _AdminReportListViewState();
}

class _AdminReportListViewState extends ConsumerState<AdminReportListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reportListViewModelProvider.notifier).loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportListViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('신고 관리'),
      ),
      body: Column(
        children: [
          // 필터 바
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FilterChipBar<ReportStatus>(
              items: const [
                FilterChipItem(value: ReportStatus.pending, label: '대기중'),
                FilterChipItem(value: ReportStatus.inReview, label: '검토중'),
                FilterChipItem(value: ReportStatus.resolved, label: '처리완료'),
                FilterChipItem(value: ReportStatus.dismissed, label: '기각'),
              ],
              selectedValue: state.selectedStatus,
              onSelected: (status) {
                ref
                    .read(reportListViewModelProvider.notifier)
                    .filterByStatus(status);
              },
            ),
          ),
          const Divider(height: 1),
          // 신고 목록
          Expanded(
            child: state.isLoading
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
                                    .read(reportListViewModelProvider.notifier)
                                    .loadReports();
                              },
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : state.reports.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  size: 64,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '신고 내역이 없습니다',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(reportListViewModelProvider.notifier)
                                  .loadReports();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: state.reports.length,
                              itemBuilder: (context, index) {
                                final report = state.reports[index];
                                return AdminReportTile(
                                  report: report,
                                  onTap: () {
                                    context.push('/admin/reports/${report.id}');
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
