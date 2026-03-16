import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/posts/models/post_models.dart';
import 'package:hidi/features/posts/mocks/post_mock.dart';
import 'package:http/http.dart' as http;

class PostRepository {
  final bool useMock;
  final basehost = Env.basehost;
  final basepath = "/api/v1/posts";

  PostRepository({this.useMock = false});

  /// 게시글 목록 조회
  Future<List<Post>> getPosts({int page = 0, int size = 20}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return getMockPosts(page: page, size: size);
    }

    // Real API
    final uri = Uri.http(basehost, basepath, {
      'page': page.toString(),
      'size': size.toString(),
    });
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("getPosts: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      final List<dynamic> content = data["content"] ?? [];
      return content.map((json) => Post.fromJson(json)).toList();
    }

    log("Error: getPosts");
    return [];
  }

  /// 게시글 상세 조회
  Future<Post?> getPost(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return getMockPostById(id);
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$id");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("getPost: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      if (data == null) return null;
      return Post.fromJson(data);
    }

    log("Error: getPost");
    return null;
  }

  /// 게시글 작성
  Future<Post?> createPost(PostCreateRequest request) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      TaggedSong? taggedSong;
      if (request.taggedSongId != null) {
        taggedSong = mockTaggedSongs.firstWhere(
          (s) => s.id == request.taggedSongId,
          orElse: () => mockTaggedSongs.first,
        );
      }
      return createMockPost(
        content: request.content,
        images: request.images,
        taggedSong: taggedSong,
      );
    }

    // Real API
    final uri = Uri.http(basehost, basepath);
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(request.toJson()),
      ),
    );

    log("createPost: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      if (data == null) return null;
      return Post.fromJson(data);
    }

    log("Error: createPost");
    return null;
  }

  /// 게시글 수정
  Future<Post?> updatePost(int id, PostUpdateRequest request) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      final post = getMockPostById(id);
      if (post == null) return null;
      TaggedSong? taggedSong;
      if (request.taggedSongId != null) {
        taggedSong = mockTaggedSongs.firstWhere(
          (s) => s.id == request.taggedSongId,
          orElse: () => mockTaggedSongs.first,
        );
      }
      return post.copyWith(
        content: request.content,
        images: request.images,
        taggedSong: taggedSong,
        updatedAt: DateTime.now(),
      );
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$id");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.put(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(request.toJson()),
      ),
    );

    log("updatePost: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      if (data == null) return null;
      return Post.fromJson(data);
    }

    log("Error: updatePost");
    return null;
  }

  /// 게시글 삭제
  Future<bool> deletePost(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$id");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("deletePost: ${response.statusCode}");
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// 좋아요 토글
  Future<bool> toggleLike(int postId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$postId/like");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("toggleLike: ${response.statusCode}");
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// 노래 검색 (태그용)
  Future<List<TaggedSong>> searchSongs(String query) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return searchMockSongs(query);
    }

    // Real API - 기존 daily-songs API 사용
    final uri = Uri.http(basehost, "/api/v1/songs/search", {'q': query});
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("searchSongs: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body)["data"] ?? [];
      return data.map((json) => TaggedSong.fromJson(json)).toList();
    }

    log("Error: searchSongs");
    return [];
  }
}

/// Mock Provider 패턴 적용
final postRepoProvider = Provider<PostRepository>((ref) {
  const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';
  return PostRepository(useMock: useMock);
});
