import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/common/common_repos.dart';
import 'package:hidi/features/users/models/user.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  final basehost = Env.basehost;
  final basepath = "/api/v1/members/me";

  Future<User?> getCurrentUser() async {
    final uri = Uri.http(basehost, basepath);

    final response = await AuthenticationRepository.requestWithRetry(
      (accessToken) => http.delete(
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
      // final user = User.fromJson(data);
      return User.empty();
    } else {
      return null;
    }
  }

  Future<void> deleteCurrentUser(Ref ref) async {
    final uri = Uri.http(basehost, basepath);
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

    CommonRepos.reponsePrint(response);
  }

  Future<bool> patchCurrentUser(String nickname, String password) async {
    final uri = Uri.http(basehost, basepath);

    Map<String, dynamic> body = {"nickname": nickname, "password": password};

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

    final data = jsonDecode(response.body)["data"];
    if (response.statusCode <= 200 && response.statusCode > 300) {
      return data["success"];
    } else {
      return false;
    }
  }
}

final userRepo = Provider((ref) => UserRepository());
