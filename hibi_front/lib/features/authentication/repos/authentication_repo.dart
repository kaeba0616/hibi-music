import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/users/models/user.dart';
import 'package:hidi/features/users/repos/users_repos.dart';
import 'package:http/http.dart' as http;

typedef TokenFunction = Future<http.Response> Function(String token);

class AuthenticationRepository {
  final basehost = Env.basehost;
  final basepath = '/api/v1/auth';

  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final UserRepository userRepo = UserRepository();
  User? _user;
  User? get user => _user;
  bool get isLoggedIn => user != null;

  Future<void> init() async {
    final accessToken = await _secureStorage.read(key: "accessToken");
    if (accessToken != null) {
      // Fetch user data if token exists
      _user = await userRepo.getCurrentUser();
      if (isLoggedIn) {
        log("User restored: ${_user?.email}");
      } else {
        await tokensClear(); // Clear tokens if user fetch fails
        _user = null;
      }
    }
  }

  Future<bool> postLocalSignup(
    String email,
    String password,
    String nickname,
  ) async {
    final uri = Uri.http(basehost, "$basepath/sign-up");

    final Map<String, dynamic> body = {
      "email": email,
      "password": password,
      "nickname": nickname,
    };

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    log("${response.statusCode}");
    final resBody = jsonDecode(response.body);
    log("body : ${resBody}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return resBody["success"];
    } else {
      log("Error: postLocalSignup");
      return false;
    }
  }

  Future<void> postSignin(String email, String password) async {
    final uri = Uri.http(basehost, "$basepath/sign-in");

    final Map<String, dynamic> body = {"email": email, "password": password};
    final response = await http.post(
      uri,
      headers: {'Content-Type': "application/json"},
      body: jsonEncode(body),
    );

    log("${response.statusCode}");
    print("${response.statusCode}");
    final resBody = jsonDecode(response.body);
    log("body : ${resBody}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = resBody["data"];
      await tokenSaves(data["accessToken"], data["refreshToken"]);
      _user = await userRepo.getCurrentUser();
      log("${isLoggedIn}");
    } else {
      log("Error: postSignin");
    }
  }

  Future<void> postSignOut(int uid) async {
    final Map<String, dynamic> queryParams = {"memberId": uid.toString()};

    final uri = Uri.http(basehost, "$basepath/sign-out", queryParams);

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode <= 200 && response.statusCode > 300) {
      await tokensClear();
      _user = null;
    } else {
      log("Error: postSignOut");
    }

    // CommonRepos.reponsePrint(response);
  }

  Future<bool> checkEmail(String email) async {
    log("checkEmail");
    final Map<String, dynamic> queryParams = {"email": email};
    final uri = Uri.http(basehost, "$basepath/check-email", queryParams);

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );
    log("${response.statusCode}");
    final resBody = jsonDecode(response.body);
    log("body : ${resBody}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return resBody["success"];
    } else {
      log("Error: checkEmail");
      return false;
    }
  }

  Future<bool> checkNickname(String nickname) async {
    final Map<String, dynamic> queryParams = {"nickname": nickname};
    final uri = Uri.http(basehost, "$basepath/check-nickname", queryParams);

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    log("${response.statusCode}");
    final resBody = jsonDecode(response.body);
    log("body : ${resBody}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return resBody["success"];
    } else {
      log("Error: checkNickname");
      return false;
    }
  }

  static Future<void> tokenSaves(
    String accessToken,
    String refreshToken,
  ) async {
    await Future.wait([
      _secureStorage.write(key: "accessToken", value: accessToken),
      _secureStorage.write(key: "refreshToken", value: refreshToken),
    ]);
  }

  static Future<void> tokensClear() async {
    await _secureStorage.deleteAll();
  }

  static Future<bool> postReissue() async {
    final _refreshToken = await _secureStorage.read(key: "refreshToken");
    log("${_refreshToken}");

    final Map<String, dynamic> queryParams = {"refreshToken": _refreshToken};
    final uri = Uri.http(
      "${Env.basehost}",
      "/api/v1/auth/reissue",
      queryParams,
    );

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    log("${response.statusCode}");
    final resBody = jsonDecode(response.body);
    log("body : ${resBody}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(resBody)["data"];
      final accessToken = data["accessToken"];
      final refreshToken = data["refreshToken"];
      await _secureStorage.write(key: "refreshToken", value: refreshToken);
      await _secureStorage.write(key: "accessToken", value: accessToken);
      return resBody["success"];
    } else {
      log("Error: postReissue");
      return false;
    }
  }

  static Future<http.Response> requestWithRetry(TokenFunction request) async {
    final accessToken = await _secureStorage.read(key: "accessToken");
    if (accessToken == null) {
      throw Exception("No access token.");
    }
    final response = await request(accessToken);
    if (response.statusCode != 401) {
      return response;
    } else {
      await postReissue();
      final newaccessToken = await _secureStorage.read(key: "accessToken");
      if (newaccessToken == null) {
        throw Exception("No new accessToken.");
      } else {
        return await request(newaccessToken);
      }
    }
  }
}

final authRepo = Provider((ref) => AuthenticationRepository());
