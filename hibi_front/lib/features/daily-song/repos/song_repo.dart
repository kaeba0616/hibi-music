import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/daily-song/models/song_model.dart';
import 'package:http/http.dart' as http;

class SongRepository {
  final basehost = Env.basehost;
  final basepath = "/api/v1/songs";

  // user
  Future<Song> getSongById(int id) async {
    final uri = Uri.http(basehost, "${basepath}/$id");
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );
    log("${response.statusCode}");
    final data = jsonDecode(response.body)["data"];
    log("data : ${data}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final song = Song.fromJson(data);
      return song;
    }

    log("Error :getSongById");
    return Song.empty();
  }

  Future<List<Song>> getSongs() async {
    final uri = Uri.http(basehost, basepath);
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );
    log("${response.statusCode}");
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body)["data"];
      log("data : ${data}");
      final songs = data.map((json) => Song.fromJson(json)).toList();
      return songs;
    }
    log("Error :getSongs");
    return [];
  }

  //  날짜(date) 형식 yyyy-MM-dd
  Future<Song> getSongByDate(String date) async {
    final Map<String, dynamic> queryParams = {"date": date};

    final uri = Uri.http(basehost, "$basepath/by-date", queryParams);
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );
    log("${response.statusCode}");
    final data = jsonDecode(response.body)["data"];
    log("data : ${data}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final song = Song.fromJson(data);
      return song;
    }

    log("Error :getSongByDate");
    return Song.empty();
  }

  Future<List<Song>> getSongsByMonthAndYear(int month, int year) async {
    final Map<String, dynamic> queryParams = {
      "month": month.toString(),
      "year": year.toString(),
    };

    final uri = Uri.http(basehost, "$basepath/by-month", queryParams);
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );
    log("${response.statusCode}");
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body)["data"];
      log("data : ${data}");
      final songs = data.map((json) => Song.fromJson(json)).toList();
      return songs;
    }
    log("Error :getSongsByMonthAndYear");
    return [];
  }
}

final songRepo = Provider((ref) => SongRepository());
