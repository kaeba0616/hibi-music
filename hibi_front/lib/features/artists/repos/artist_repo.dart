import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/artists/models/artist_model.dart';
import 'package:hidi/features/artists/models/artist_detail_model.dart';
import 'package:hidi/features/artists/mocks/artist_mock.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:http/http.dart' as http;

class ArtistRepository {
  final bool useMock;
  final basehost = Env.basehost;
  final basepath = "/api/v1/artists";

  ArtistRepository({this.useMock = false});

  /// 아티스트 목록 가져오기
  Future<List<Artist>> getArtists({
    bool? followingOnly,
    String? searchQuery,
    int page = 0,
    int size = 20,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return getMockArtists(followingOnly: followingOnly, searchQuery: searchQuery);
    }

    // Real API
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (followingOnly == true) {
      queryParams['following'] = 'true';
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search'] = searchQuery;
    }

    final uri = Uri.http(basehost, basepath, queryParams);
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("getArtists: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      final List<dynamic> content = data["content"] ?? [];
      return content.map((json) => Artist.fromJson(json)).toList();
    }

    log("Error: getArtists");
    return [];
  }

  /// 아티스트 상세 가져오기
  Future<ArtistDetail?> getArtistDetail(int artistId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return getMockArtistDetail(artistId);
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$artistId");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("getArtistDetail: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      if (data == null) return null;
      return ArtistDetail.fromJson(data);
    }

    log("Error: getArtistDetail");
    return null;
  }

  /// 팔로우하기
  Future<bool> follow(int artistId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      toggleMockFollow(artistId);
      return true;
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$artistId/follow");
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

  /// 언팔로우하기
  Future<bool> unfollow(int artistId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      toggleMockFollow(artistId);
      return true;
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$artistId/follow");
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
}

/// Mock Provider 패턴 적용
final artistRepoProvider = Provider<ArtistRepository>((ref) {
  const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';
  return ArtistRepository(useMock: useMock);
});
