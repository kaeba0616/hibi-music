import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/common/common_repos.dart';
import 'package:hidi/features/users/models/my_comment.dart';
import 'package:hidi/features/users/models/user.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  final basehost = Env.basehost;
  final basepath = "/api/v1/members/me";

  Future<User?> getCurrentUser() async {
    final uri = Env.apiUri(basepath);

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
      final data = jsonDecode(response.body)["data"];
      return User.fromJson(data);
    } else {
      return null;
    }
  }

  /// 내가 쓴 댓글 목록 - GET /api/v1/members/me/comments
  Future<List<MyComment>> getMyComments() async {
    final uri = Env.apiUri("$basepath/comments");

    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );
    log("getMyComments: ${response.statusCode}");
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body)["data"] ?? [];
      return data
          .map((json) => MyComment.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> deleteCurrentUser(Ref ref) async {
    final uri = Env.apiUri(basepath);
    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.delete(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      await AuthenticationRepository.tokensClear();
    }

    CommonRepos.responsePrint(response);
  }

  Future<bool> patchCurrentUser(String nickname, String password) async {
    final uri = Env.apiUri(basepath);

    // 부분 수정: 빈 필드는 보내지 않는다 (백엔드는 포함된 필드만 검증/변경)
    Map<String, dynamic> body = {
      if (nickname.isNotEmpty) "nickname": nickname,
      if (password.isNotEmpty) "password": password,
    };
    if (body.isEmpty) return false;

    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.patch(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(body),
      ),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body)["success"] == true;
    } else {
      return false;
    }
  }
}

final userRepo = Provider((ref) => UserRepository());
