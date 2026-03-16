import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/follow/mocks/follow_mock.dart';
import 'package:hidi/features/follow/models/follow_models.dart';
import 'package:hidi/features/posts/models/post_models.dart';
import 'package:http/http.dart' as http;

/// 팔로우 Repository
class FollowRepository {
  final bool useMock;
  final basehost = Env.basehost;
  final basepath = "/api/v1/users";
  final postBasepath = "/api/v1/posts";

  FollowRepository({this.useMock = false});

  /// 사용자 프로필 조회
  Future<UserProfile?> getUserProfile(int userId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return getMockUserProfile(userId);
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$userId");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("getUserProfile: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      if (data == null) return null;
      return UserProfile.fromJson(data);
    }

    log("Error: getUserProfile");
    return null;
  }

  /// 팔로워 목록 조회
  Future<FollowListResponse> getFollowers(int userId, {int page = 0, int size = 20}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return getMockFollowers(userId);
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$userId/followers", {
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

    log("getFollowers: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      if (data == null) return FollowListResponse.empty();
      return FollowListResponse.fromJson(data);
    }

    log("Error: getFollowers");
    return FollowListResponse.empty();
  }

  /// 팔로잉 목록 조회
  Future<FollowListResponse> getFollowing(int userId, {int page = 0, int size = 20}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return getMockFollowing(userId);
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$userId/followings", {
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

    log("getFollowing: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      if (data == null) return FollowListResponse.empty();
      return FollowListResponse.fromJson(data);
    }

    log("Error: getFollowing");
    return FollowListResponse.empty();
  }

  /// 팔로우
  Future<bool> follow(int userId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      toggleMockFollow(userId);
      return true;
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$userId/follow");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("follow: ${response.statusCode}");
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// 언팔로우
  Future<bool> unfollow(int userId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      toggleMockFollow(userId);
      return true;
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$userId/follow");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("unfollow: ${response.statusCode}");
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// 사용자 게시글 목록 조회
  Future<List<Post>> getUserPosts(int userId, {int page = 0, int size = 20}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return getMockUserPosts(userId, page: page, size: size);
    }

    // Real API - FeedPostController에 사용자 게시글 엔드포인트 필요
    // 현재는 전체 게시글에서 필터링하는 방식 사용
    final uri = Uri.http(basehost, "$basepath/$userId/posts", {
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

    log("getUserPosts: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      final List<dynamic> content = data["content"] ?? [];
      return content.map((json) => Post.fromJson(json)).toList();
    }

    log("Error: getUserPosts");
    return [];
  }

  /// 팔로잉 피드 조회
  Future<List<Post>> getFollowingFeed({int page = 0, int size = 20}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final posts = getMockFollowingFeed();
      final start = page * size;
      if (start >= posts.length) return [];
      final end = (start + size).clamp(0, posts.length);
      return posts.sublist(start, end);
    }

    // Real API
    final uri = Uri.http(basehost, "$postBasepath/following", {
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

    log("getFollowingFeed: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      final List<dynamic> content = data["content"] ?? [];
      return content.map((json) => Post.fromJson(json)).toList();
    }

    log("Error: getFollowingFeed");
    return [];
  }
}

/// Mock Provider 패턴 적용
final followRepoProvider = Provider<FollowRepository>((ref) {
  const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';
  return FollowRepository(useMock: useMock);
});
