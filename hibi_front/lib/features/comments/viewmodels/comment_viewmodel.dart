import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/comments/mocks/comment_mock.dart';
import 'package:hidi/features/comments/models/comment_models.dart';
import 'package:hidi/features/comments/repos/comment_repo.dart';

/// 댓글 섹션 상태
class CommentSectionState {
  final List<Comment> comments;
  final int totalCount;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final Comment? replyTo;

  CommentSectionState({
    this.comments = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.replyTo,
  });

  CommentSectionState copyWith({
    List<Comment>? comments,
    int? totalCount,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    Comment? replyTo,
    bool clearError = false,
    bool clearReplyTo = false,
  }) {
    return CommentSectionState(
      comments: comments ?? this.comments,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      replyTo: clearReplyTo ? null : (replyTo ?? this.replyTo),
    );
  }

  /// 댓글이 비어있는지 확인
  bool get isEmpty => comments.isEmpty;

  /// 대댓글 모드인지 확인
  bool get isReplyMode => replyTo != null;
}

/// 댓글 섹션 ViewModel (게시글별)
class CommentSectionViewModel extends FamilyNotifier<CommentSectionState, int> {
  late final CommentRepository _repo;
  late final int _postId;

  @override
  CommentSectionState build(int postId) {
    _repo = ref.read(commentRepoProvider);
    _postId = postId;
    Future.microtask(() => loadComments());
    return CommentSectionState(isLoading: true);
  }

  /// 현재 사용자 ID (Mock용)
  int get currentUserId => mockCurrentUserId;

  /// 댓글 목록 로드
  Future<void> loadComments() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _repo.getComments(_postId);
      state = state.copyWith(
        comments: response.comments,
        totalCount: response.totalCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '댓글을 불러오는데 실패했습니다',
      );
    }
  }

  /// 댓글 작성
  Future<bool> submitComment(String content) async {
    if (content.trim().isEmpty) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final request = CommentCreateRequest(
        postId: _postId,
        content: content,
        parentId: state.replyTo?.id,
      );

      final newComment = await _repo.createComment(request);
      if (newComment == null) {
        state = state.copyWith(
          isSubmitting: false,
          error: '댓글 작성에 실패했습니다',
        );
        return false;
      }

      // 댓글 목록 업데이트
      List<Comment> updatedComments;
      if (state.replyTo != null) {
        // 대댓글인 경우: 부모 댓글의 replies에 추가
        updatedComments = _addReplyToComment(
          state.comments,
          state.replyTo!.id,
          newComment,
        );
      } else {
        // 일반 댓글인 경우: 목록 끝에 추가
        updatedComments = [...state.comments, newComment];
      }

      state = state.copyWith(
        comments: updatedComments,
        totalCount: state.totalCount + 1,
        isSubmitting: false,
        clearReplyTo: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: '댓글 작성에 실패했습니다',
      );
      return false;
    }
  }

  /// 댓글 삭제
  Future<bool> deleteComment(int commentId) async {
    try {
      final success = await _repo.deleteComment(_postId, commentId);
      if (success) {
        // 댓글 목록에서 삭제 처리
        final updatedComments = _deleteCommentFromList(state.comments, commentId);
        final deletedCount = _countDeletedComments(state.comments, commentId);

        state = state.copyWith(
          comments: updatedComments,
          totalCount: state.totalCount - deletedCount,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: '댓글 삭제에 실패했습니다');
      return false;
    }
  }

  /// 댓글 좋아요 토글
  Future<void> toggleLike(int commentId) async {
    // 낙관적 업데이트
    final updatedComments = _toggleLikeInList(state.comments, commentId);
    state = state.copyWith(comments: updatedComments);

    try {
      await _repo.toggleLike(_postId, commentId);
    } catch (e) {
      // 실패 시 롤백
      final rolledBack = _toggleLikeInList(state.comments, commentId);
      state = state.copyWith(
        comments: rolledBack,
        error: '좋아요 처리에 실패했습니다',
      );
    }
  }

  /// 대댓글 모드 시작
  void startReply(Comment comment) {
    state = state.copyWith(replyTo: comment);
  }

  /// 대댓글 모드 취소
  void cancelReply() {
    state = state.copyWith(clearReplyTo: true);
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// 대댓글 추가 헬퍼
  List<Comment> _addReplyToComment(
    List<Comment> comments,
    int parentId,
    Comment newReply,
  ) {
    return comments.map((comment) {
      if (comment.id == parentId) {
        return comment.copyWith(
          replies: [...comment.replies, newReply],
        );
      }
      return comment;
    }).toList();
  }

  /// 댓글 삭제 헬퍼 (soft delete 처리)
  List<Comment> _deleteCommentFromList(List<Comment> comments, int commentId) {
    List<Comment> result = [];

    for (final comment in comments) {
      if (comment.id == commentId) {
        // 대댓글이 있으면 soft delete
        if (comment.replies.isNotEmpty) {
          result.add(Comment.deleted(
            id: comment.id,
            postId: comment.postId,
            createdAt: comment.createdAt,
            replies: comment.replies,
          ));
        }
        // 대댓글이 없으면 완전 삭제 (result에 추가하지 않음)
      } else {
        // 대댓글에서 삭제 확인
        final updatedReplies = comment.replies
            .where((reply) => reply.id != commentId)
            .toList();

        result.add(comment.copyWith(replies: updatedReplies));
      }
    }

    return result;
  }

  /// 삭제되는 댓글 수 계산
  int _countDeletedComments(List<Comment> comments, int commentId) {
    for (final comment in comments) {
      if (comment.id == commentId) {
        // 대댓글이 없으면 1개 삭제
        return comment.replies.isEmpty ? 1 : 1;
      }
      // 대댓글에서 확인
      for (final reply in comment.replies) {
        if (reply.id == commentId) {
          return 1;
        }
      }
    }
    return 0;
  }

  /// 좋아요 토글 헬퍼
  List<Comment> _toggleLikeInList(List<Comment> comments, int commentId) {
    return comments.map((comment) {
      if (comment.id == commentId) {
        return comment.copyWith(
          isLiked: !comment.isLiked,
          likeCount: comment.isLiked
              ? comment.likeCount - 1
              : comment.likeCount + 1,
        );
      }
      // 대댓글에서 확인
      final updatedReplies = comment.replies.map((reply) {
        if (reply.id == commentId) {
          return reply.copyWith(
            isLiked: !reply.isLiked,
            likeCount:
                reply.isLiked ? reply.likeCount - 1 : reply.likeCount + 1,
          );
        }
        return reply;
      }).toList();

      return comment.copyWith(replies: updatedReplies);
    }).toList();
  }
}

/// 댓글 섹션 ViewModel Provider (게시글별)
final commentSectionViewModelProvider = NotifierProvider.family<
    CommentSectionViewModel, CommentSectionState, int>(
  CommentSectionViewModel.new,
);
