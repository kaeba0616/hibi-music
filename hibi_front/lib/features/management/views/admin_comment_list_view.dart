/// AE-03: 댓글 관리 화면

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/admin_song_models.dart';
import '../viewmodels/admin_comment_viewmodel.dart';
import '../widgets/filter_chip_bar.dart';

class AdminCommentListView extends ConsumerStatefulWidget {
  const AdminCommentListView({super.key});

  @override
  ConsumerState<AdminCommentListView> createState() =>
      _AdminCommentListViewState();
}

class _AdminCommentListViewState extends ConsumerState<AdminCommentListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminCommentListViewModelProvider.notifier).loadComments();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(adminCommentListViewModelProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCommentListViewModelProvider);
    final vm = ref.read(adminCommentListViewModelProvider.notifier);
    final theme = Theme.of(context);

    ref.listen(adminCommentListViewModelProvider, (prev, next) {
      if (next.successMessage != null &&
          prev?.successMessage != next.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!)),
        );
      }
      if (next.errorMessage != null &&
          prev?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('댓글 관리'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '총 ${state.totalCount}개',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 바
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FilterChipBar<CommentFilter>(
              items: CommentFilter.values
                  .map((f) =>
                      FilterChipItem(value: f, label: f.displayName))
                  .toList(),
              selectedValue: state.filter,
              onSelected: (filter) {
                if (filter != null) {
                  vm.changeFilter(filter);
                } else {
                  vm.changeFilter(CommentFilter.all);
                }
              },
            ),
          ),

          // 댓글 목록
          Expanded(
            child: state.isLoading && state.comments.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '댓글이 없습니다',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => vm.loadComments(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.comments.length +
                              (state.isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.comments.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              );
                            }
                            return _buildCommentTile(
                              context,
                              state.comments[index],
                              vm,
                              theme,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(
    BuildContext context,
    AdminCommentItem comment,
    AdminCommentListViewModel vm,
    ThemeData theme,
  ) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 작성자 + 작성일
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text(
                    comment.authorNickname[0].toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  comment.authorNickname,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(comment.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 댓글 내용
            Text(
              comment.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: comment.isFiltered
                  ? theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontStyle: FontStyle.italic,
                    )
                  : theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 8),

            // 하단: 통계 + 삭제 버튼
            Row(
              children: [
                Text(
                  '게시글 #${comment.feedPostId}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.favorite_border, size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 2),
                Text(
                  '${comment.likeCount}',
                  style: theme.textTheme.bodySmall,
                ),
                if (comment.reportCount > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag,
                            size: 12, color: theme.colorScheme.error),
                        const SizedBox(width: 2),
                        Text(
                          '신고 ${comment.reportCount}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (comment.isFiltered) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '필터됨',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: theme.colorScheme.error, size: 20),
                  onPressed: () =>
                      _showDeleteDialog(context, vm, comment),
                  tooltip: '삭제',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AdminCommentListViewModel vm,
    AdminCommentItem comment,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: Text(
          '\'${comment.authorNickname}\'의 댓글을 삭제하시겠습니까?\n\n"${comment.content.length > 50 ? '${comment.content.substring(0, 50)}...' : comment.content}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              vm.deleteComment(comment.id);
              Navigator.of(context).pop();
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
