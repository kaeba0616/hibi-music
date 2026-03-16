import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/comments/mocks/comment_mock.dart';
import 'package:hidi/features/comments/models/comment_models.dart';
import 'package:http/http.dart' as http;

/// 댓글 Repository
class CommentRepository {
  final bool useMock;
  final basehost = Env.basehost;

  CommentRepository({this.useMock = false});

  String _basepath(int postId) => "/api/v1/posts/$postId/comments";

  /// 댓글 목록 조회
  Future<CommentListResponse> getComments(int postId) async {
    if (useMock) {
      // Mock 딜레이 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 500));
      final comments = getMockCommentsForPost(postId);
      return CommentListResponse(
        comments: comments,
        totalCount: getMockCommentCount(postId),
        hasMore: false,
      );
    }

    // Real API
    final uri = Uri.http(basehost, _basepath(postId));
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("getComments: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      if (data == null) {
        return CommentListResponse(
          comments: [],
          totalCount: 0,
          hasMore: false,
        );
      }
      return CommentListResponse.fromJson(data);
    }

    log("Error: getComments");
    return CommentListResponse(
      comments: [],
      totalCount: 0,
      hasMore: false,
    );
  }

  /// 댓글 작성
  Future<Comment?> createComment(CommentCreateRequest request) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock 새 댓글 생성
      final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch,
        postId: request.postId,
        author: mockCommentAuthors[mockCurrentUserId - 1],
        content: request.content,
        parentId: request.parentId,
        parentAuthorNickname: request.parentId != null
            ? _findParentAuthorNickname(request.postId, request.parentId!)
            : null,
        likeCount: 0,
        isLiked: false,
        createdAt: DateTime.now(),
      );
      return newComment;
    }

    // Real API
    final uri = Uri.http(basehost, _basepath(request.postId));
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode({
          'content': request.content,
          'parentId': request.parentId,
        }),
      ),
    );

    log("createComment: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      if (data == null) return null;
      return Comment.fromJson(data);
    }

    log("Error: createComment");
    return null;
  }

  /// 댓글 삭제
  Future<bool> deleteComment(int postId, int commentId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      // Mock에서는 항상 성공
      return true;
    }

    // Real API
    final uri = Uri.http(basehost, "${_basepath(postId)}/$commentId");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("deleteComment: ${response.statusCode}");
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// 댓글 좋아요 토글
  Future<bool> toggleLike(int postId, int commentId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      // Mock에서는 항상 성공
      return true;
    }

    // Real API
    final uri = Uri.http(basehost, "${_basepath(postId)}/$commentId/like");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("toggleCommentLike: ${response.statusCode}");
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// 부모 댓글 작성자 닉네임 찾기 (Mock용)
  String? _findParentAuthorNickname(int postId, int parentId) {
    final comments = getMockCommentsForPost(postId);
    for (final comment in comments) {
      if (comment.id == parentId) {
        return comment.isDeleted ? '삭제됨' : comment.author.nickname;
      }
    }
    return null;
  }
}

/// CommentRepository Provider
final commentRepoProvider = Provider<CommentRepository>((ref) {
  final useMock =
      const String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';
  return CommentRepository(useMock: useMock);
});
