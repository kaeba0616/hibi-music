/// MG-08: 회원 목록 화면

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/admin_models.dart';
import '../viewmodels/admin_member_viewmodel.dart';
import '../widgets/admin_member_tile.dart';
import '../widgets/filter_chip_bar.dart';

class AdminMemberListView extends ConsumerStatefulWidget {
  const AdminMemberListView({super.key});

  @override
  ConsumerState<AdminMemberListView> createState() =>
      _AdminMemberListViewState();
}

class _AdminMemberListViewState extends ConsumerState<AdminMemberListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(memberListViewModelProvider.notifier).loadMembers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberListViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 관리'),
      ),
      body: Column(
        children: [
          // 검색 바
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '닉네임 또는 이메일로 검색',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) {
                ref.read(memberListViewModelProvider.notifier).search(value);
              },
            ),
          ),
          // 필터 바
          FilterChipBar<MemberStatus>(
            items: const [
              FilterChipItem(value: MemberStatus.active, label: '활성'),
              FilterChipItem(value: MemberStatus.suspended, label: '정지'),
              FilterChipItem(value: MemberStatus.banned, label: '탈퇴'),
            ],
            selectedValue: state.selectedStatus,
            onSelected: (status) {
              ref
                  .read(memberListViewModelProvider.notifier)
                  .filterByStatus(status);
            },
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // 회원 목록
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
                                    .read(memberListViewModelProvider.notifier)
                                    .loadMembers();
                              },
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : state.members.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.searchQuery.isNotEmpty
                                      ? '검색 결과가 없습니다'
                                      : '회원이 없습니다',
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
                                  .read(memberListViewModelProvider.notifier)
                                  .loadMembers();
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    '총 ${state.totalCount}명',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    itemCount: state.members.length,
                                    itemBuilder: (context, index) {
                                      final member = state.members[index];
                                      return AdminMemberTile(
                                        member: member,
                                        onTap: () {
                                          context.push(
                                              '/admin/members/${member.id}');
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
