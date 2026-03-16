import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/search/mocks/search_mock.dart' as mock;
import 'package:hidi/features/search/models/search_models.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 검색 Repository
class SearchRepository {
  final bool useMock;
  final basehost = Env.basehost;
  final basepath = "/api/v1/search";

  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  SearchRepository({this.useMock = false});

  /// 통합 검색
  Future<SearchResult> search(String query, {SearchCategory category = SearchCategory.all}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return mock.searchMock(query);
    }

    // Real API
    final categoryParam = _getCategoryParam(category);
    final uri = Uri.http(basehost, basepath, {
      'q': query,
      'category': categoryParam,
      'limit': '20',
    });

    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          if (accessToken.isNotEmpty) "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("search: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      if (data == null) return SearchResult.empty();
      return _parseSearchResponse(data);
    }

    log("Error: search");
    return SearchResult.empty();
  }

  String _getCategoryParam(SearchCategory category) {
    switch (category) {
      case SearchCategory.all:
        return 'all';
      case SearchCategory.songs:
        return 'songs';
      case SearchCategory.artists:
        return 'artists';
      case SearchCategory.posts:
        return 'posts';
      case SearchCategory.users:
        return 'users';
    }
  }

  SearchResult _parseSearchResponse(Map<String, dynamic> data) {
    final songs = (data['songs'] as List<dynamic>?)
            ?.map((e) => SearchSong.fromJson(e))
            .toList() ??
        [];
    final artists = (data['artists'] as List<dynamic>?)
            ?.map((e) => SearchArtist.fromJson(e))
            .toList() ??
        [];
    final posts = (data['posts'] as List<dynamic>?)
            ?.map((e) => SearchPost.fromJson(e))
            .toList() ??
        [];
    final users = (data['users'] as List<dynamic>?)
            ?.map((e) => SearchUser.fromJson(e))
            .toList() ??
        [];

    final totalCount = data['totalCount'] as Map<String, dynamic>?;

    return SearchResult(
      songs: songs,
      artists: artists,
      posts: posts,
      users: users,
      totalSongs: totalCount?['songs'] ?? songs.length,
      totalArtists: totalCount?['artists'] ?? artists.length,
      totalPosts: totalCount?['posts'] ?? posts.length,
      totalUsers: totalCount?['users'] ?? users.length,
    );
  }

  /// 노래만 검색
  Future<List<SearchSong>> searchSongs(String query, {int page = 0, int size = 20}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final result = mock.searchMock(query);
      return result.songs;
    }

    final result = await search(query, category: SearchCategory.songs);
    return result.songs;
  }

  /// 아티스트만 검색
  Future<List<SearchArtist>> searchArtists(String query, {int page = 0, int size = 20}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final result = mock.searchMock(query);
      return result.artists;
    }

    final result = await search(query, category: SearchCategory.artists);
    return result.artists;
  }

  /// 게시글만 검색
  Future<List<SearchPost>> searchPosts(String query, {int page = 0, int size = 20}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final result = mock.searchMock(query);
      return result.posts;
    }

    final result = await search(query, category: SearchCategory.posts);
    return result.posts;
  }

  /// 사용자만 검색
  Future<List<SearchUser>> searchUsers(String query, {int page = 0, int size = 20}) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final result = mock.searchMock(query);
      return result.users;
    }

    final result = await search(query, category: SearchCategory.users);
    return result.users;
  }

  /// 최근 검색어 목록 조회 (로컬 저장소)
  Future<List<RecentSearch>> getRecentSearches() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 100));
      return List.from(mock.mockRecentSearches);
    }

    // Real: 로컬 저장소에서 조회
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentSearchesKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => RecentSearch.fromJson(e)).toList();
    } catch (e) {
      log("Error loading recent searches: $e");
      return [];
    }
  }

  /// 최근 검색어 추가 (로컬 저장소)
  Future<void> addRecentSearch(String query) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 50));
      mock.addRecentSearch(query);
      return;
    }

    // Real: 로컬 저장소에 저장
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = await getRecentSearches();

      // 중복 제거
      searches.removeWhere((s) => s.query == query);

      // 맨 앞에 추가
      searches.insert(0, RecentSearch(query: query, searchedAt: DateTime.now()));

      // 최대 개수 유지
      while (searches.length > _maxRecentSearches) {
        searches.removeLast();
      }

      final jsonString = jsonEncode(searches.map((e) => e.toJson()).toList());
      await prefs.setString(_recentSearchesKey, jsonString);
    } catch (e) {
      log("Error saving recent search: $e");
    }
  }

  /// 최근 검색어 삭제 (로컬 저장소)
  Future<void> deleteRecentSearch(String query) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 50));
      mock.removeRecentSearch(query);
      return;
    }

    // Real: 로컬 저장소에서 삭제
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = await getRecentSearches();

      searches.removeWhere((s) => s.query == query);

      final jsonString = jsonEncode(searches.map((e) => e.toJson()).toList());
      await prefs.setString(_recentSearchesKey, jsonString);
    } catch (e) {
      log("Error deleting recent search: $e");
    }
  }

  /// 최근 검색어 전체 삭제 (로컬 저장소)
  Future<void> clearAllRecentSearches() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 50));
      mock.clearRecentSearches();
      return;
    }

    // Real: 로컬 저장소 초기화
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
    } catch (e) {
      log("Error clearing recent searches: $e");
    }
  }

  /// 인기 검색어 조회
  Future<List<String>> getPopularKeywords() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 100));
      return mock.popularKeywords;
    }

    // Real: 서버에서 인기 검색어 API 호출 (미구현 시 빈 리스트)
    // TODO: 인기 검색어 API 구현 시 연동
    return [];
  }

  /// 아티스트 팔로우 토글
  Future<bool> toggleArtistFollow(int artistId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      mock.toggleArtistFollow(artistId);
      return true;
    }

    // Real API - 기존 Artist Follow API 사용
    final uri = Uri.http(basehost, "/api/v1/artists/$artistId/follow");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("toggleArtistFollow: ${response.statusCode}");
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// 사용자 팔로우 토글
  Future<bool> toggleUserFollow(int userId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      mock.toggleUserFollow(userId);
      return true;
    }

    // Real API - 기존 User Follow API 사용
    final uri = Uri.http(basehost, "/api/v1/users/$userId/follow");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("toggleUserFollow: ${response.statusCode}");
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}

/// Mock Provider 패턴 적용
final searchRepoProvider = Provider<SearchRepository>((ref) {
  const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';
  return SearchRepository(useMock: useMock);
});
