/// F18 관리자 댓글 관리 ViewModel

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_song_models.dart';
import '../repos/admin_repo.dart';

/// 댓글 필터
enum CommentFilter {
  all('전체'),
  reported('신고된 댓글');

  const CommentFilter(this.displayName);
  final String displayName;
}

/// 댓글 관리 상태
class AdminCommentListState {
  final List<AdminCommentItem> comments;
  final int totalCount;
  final int page;
  final bool isLoading;
  final bool hasMore;
  final CommentFilter filter;
  final String? errorMessage;
  final String? successMessage;

  const AdminCommentListState({
    this.comments = const [],
    this.totalCount = 0,
    this.page = 0,
    this.isLoading = false,
    this.hasMore = true,
    this.filter = CommentFilter.all,
    this.errorMessage,
    this.successMessage,
  });

  AdminCommentListState copyWith({
    List<AdminCommentItem>? comments,
    int? totalCount,
    int? page,
    bool? isLoading,
    bool? hasMore,
    CommentFilter? filter,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminCommentListState(
      comments: comments ?? this.comments,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// 댓글 관리 ViewModel
class AdminCommentListViewModel extends StateNotifier<AdminCommentListState> {
  final AdminRepository _repository;

  AdminCommentListViewModel(this._repository)
      : super(const AdminCommentListState());

  /// 댓글 목록 로드
  Future<void> loadComments({CommentFilter? filter}) async {
    final selectedFilter = filter ?? state.filter;
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      filter: selectedFilter,
      page: 0,
    );

    try {
      final onlyReported = selectedFilter == CommentFilter.reported;
      final response = await _repository.getAdminComments(
        onlyReported: onlyReported,
        page: 0,
      );

      state = state.copyWith(
        comments: response.comments,
        totalCount: response.totalCount,
        isLoading: false,
        hasMore: response.comments.length < response.totalCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '댓글 목록을 불러오는데 실패했습니다',
      );
    }
  }

  /// 다음 페이지 로드
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.page + 1;
    state = state.copyWith(isLoading: true);

    try {
      final onlyReported = state.filter == CommentFilter.reported;
      final response = await _repository.getAdminComments(
        onlyReported: onlyReported,
        page: nextPage,
      );

      state = state.copyWith(
        comments: [...state.comments, ...response.comments],
        totalCount: response.totalCount,
        page: nextPage,
        isLoading: false,
        hasMore:
            state.comments.length + response.comments.length < response.totalCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '댓글 목록을 불러오는데 실패했습니다',
      );
    }
  }

  /// 필터 변경
  void changeFilter(CommentFilter filter) {
    loadComments(filter: filter);
  }

  /// 댓글 삭제
  Future<void> deleteComment(int commentId) async {
    try {
      await _repository.deleteAdminComment(commentId);

      final updated =
          state.comments.where((c) => c.id != commentId).toList();
      state = state.copyWith(
        comments: updated,
        totalCount: state.totalCount - 1,
        successMessage: '댓글이 삭제되었습니다',
      );
    } catch (e) {
      state = state.copyWith(errorMessage: '댓글 삭제에 실패했습니다');
    }
  }
}

/// 댓글 관리 ViewModel Provider
final adminCommentListViewModelProvider =
    StateNotifierProvider<AdminCommentListViewModel, AdminCommentListState>(
        (ref) {
  final repository = ref.watch(adminRepoProvider);
  return AdminCommentListViewModel(repository);
});
