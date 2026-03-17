/// MG-01: 관리자 대시보드 화면

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/admin_dashboard_viewmodel.dart';
import '../widgets/admin_menu_tile.dart';
import '../widgets/admin_stat_card.dart';
import 'admin_song_register_view.dart';
import 'admin_scheduled_publish_view.dart';
import 'admin_comment_list_view.dart';

class AdminDashboardView extends ConsumerStatefulWidget {
  const AdminDashboardView({super.key});

  @override
  ConsumerState<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends ConsumerState<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dashboardViewModelProvider.notifier).loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자'),
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
                              .read(dashboardViewModelProvider.notifier)
                              .loadStats();
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(dashboardViewModelProvider.notifier)
                        .loadStats();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 통계 카드
                        if (state.stats != null) ...[
                          Text(
                            '대시보드',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.2,
                            children: [
                              AdminStatCard(
                                icon: Icons.flag,
                                label: '미처리 신고',
                                count: state.stats!.pendingReports,
                                iconColor: theme.colorScheme.error,
                                onTap: () => context.push('/admin/reports'),
                              ),
                              AdminStatCard(
                                icon: Icons.help,
                                label: '미답변 문의',
                                count: state.stats!.pendingQuestions,
                                iconColor: Colors.orange,
                                onTap: () => context.push('/admin/questions'),
                              ),
                              AdminStatCard(
                                icon: Icons.people,
                                label: '전체 회원',
                                count: state.stats!.totalMembers,
                                sublabel: '오늘 +${state.stats!.todayNewMembers}',
                                onTap: () => context.push('/admin/members'),
                              ),
                              AdminStatCard(
                                icon: Icons.music_note,
                                label: '전체 노래',
                                count: state.stats!.totalSongs,
                                sublabel: '오늘 +${state.stats!.todayNewSongs}',
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 32),
                        // 메뉴 목록
                        Text(
                          '관리 메뉴',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Column(
                            children: [
                              AdminMenuTile(
                                icon: Icons.flag,
                                title: '신고 관리',
                                badge: state.stats?.pendingReports.toString(),
                                onTap: () => context.push('/admin/reports'),
                              ),
                              const Divider(height: 1),
                              AdminMenuTile(
                                icon: Icons.help_outline,
                                title: '문의 관리',
                                badge: state.stats?.pendingQuestions.toString(),
                                onTap: () => context.push('/admin/questions'),
                              ),
                              const Divider(height: 1),
                              AdminMenuTile(
                                icon: Icons.quiz,
                                title: 'FAQ 관리',
                                onTap: () => context.push('/admin/faqs'),
                              ),
                              const Divider(height: 1),
                              AdminMenuTile(
                                icon: Icons.people,
                                title: '회원 관리',
                                onTap: () => context.push('/admin/members'),
                              ),
                              const Divider(height: 1),
                              AdminMenuTile(
                                icon: Icons.music_note,
                                title: '곡 등록',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminSongRegisterView(),
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                              AdminMenuTile(
                                icon: Icons.schedule_send,
                                title: '예약 게시',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminScheduledPublishView(),
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                              AdminMenuTile(
                                icon: Icons.comment,
                                title: '댓글 관리',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminCommentListView(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
