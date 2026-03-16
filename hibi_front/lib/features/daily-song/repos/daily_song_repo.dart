import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';
import 'package:hidi/features/daily-song/mocks/daily_song_mock.dart';
import 'package:http/http.dart' as http;

class DailySongRepository {
  final bool useMock;
  final basehost = Env.basehost;
  final basepath = "/api/v1/daily-songs";

  DailySongRepository({this.useMock = false});

  /// 오늘의 노래 가져오기
  Future<DailySong?> getTodaySong() async {
    if (useMock) {
      // Mock 사용시 약간의 딜레이 추가 (실제 API 느낌)
      await Future.delayed(const Duration(milliseconds: 500));
      return getMockTodaySong();
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/today");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("getTodaySong: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      if (data == null) return null;
      return DailySong.fromJson(data);
    }

    log("Error: getTodaySong");
    return null;
  }

  /// 날짜별 노래 가져오기
  Future<DailySong?> getSongByDate(DateTime date) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return getMockSongByDate(date);
    }

    // Real API
    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final uri = Uri.http(basehost, "$basepath/by-date", {"date": dateStr});
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    log("getSongByDate: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      if (data == null) return null;
      return DailySong.fromJson(data);
    }

    log("Error: getSongByDate");
    return null;
  }

  /// ID로 노래 상세 정보 가져오기
  Future<DailySong?> getSongById(int id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return getMockSongById(id);
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

    log("getSongById: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body)["data"];
      if (data == null) return null;
      return DailySong.fromJson(data);
    }

    log("Error: getSongById");
    return null;
  }

  /// 월별 노래 목록 가져오기
  Future<List<DailySong>> getSongsByMonth(int year, int month) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return getMockSongsByMonth(year, month);
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/by-month", {
      "year": year.toString(),
      "month": month.toString(),
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

    log("getSongsByMonth: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body)["data"] ?? [];
      return data.map((json) => DailySong.fromJson(json)).toList();
    }

    log("Error: getSongsByMonth");
    return [];
  }

  /// 좋아요 토글
  Future<bool> toggleLike(int songId) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      // Mock에서는 항상 성공
      return true;
    }

    // Real API
    final uri = Uri.http(basehost, "$basepath/$songId/like");
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

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    log("Error: toggleLike");
    return false;
  }
}

/// Mock Provider 패턴 적용
final dailySongRepoProvider = Provider<DailySongRepository>((ref) {
  const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';
  return DailySongRepository(useMock: useMock);
});
