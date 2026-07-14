import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/utils/token_storage.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/users/models/user.dart';
import 'package:hidi/features/users/repos/users_repos.dart';
import 'package:http/http.dart' as http;

typedef TokenFunction = Future<http.Response> Function(String token);

/// 로그인/로그아웃/세션만료 시점을 라우터 등에 알리는 Listenable.
class AuthStateNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class AuthenticationRepository {
  final basepath = '/api/v1/auth';

  static final TokenStorage _secureStorage = TokenStorage();
  final UserRepository userRepo = UserRepository();

  /// 세션은 앱 전역에 하나이므로 static으로 관리한다.
  /// (requestWithRetry 등 static 경로에서도 세션 만료를 반영하기 위함)
  static User? _user;
  User? get user => _user;
  bool get isLoggedIn => user != null;

  /// GoRouter refreshListenable 연결용 인증 상태 변경 알림.
  static final AuthStateNotifier authStateChanges = AuthStateNotifier();

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
      authStateChanges.notify();
    }
  }

  Future<bool> postLocalSignup(
    String email,
    String password,
    String nickname,
  ) async {
    final uri = Env.apiUri("$basepath/sign-up");

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

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body)["success"] == true;
    } else {
      log("Error: postLocalSignup");
      return false;
    }
  }

  Future<void> postSignin(String email, String password) async {
    final uri = Env.apiUri("$basepath/sign-in");

    final Map<String, dynamic> body = {"email": email, "password": password};
    final response = await http.post(
      uri,
      headers: {'Content-Type': "application/json"},
      body: jsonEncode(body),
    );

    log("${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final resBody = jsonDecode(response.body);
      final data = resBody["data"];
      await tokenSaves(data["accessToken"], data["refreshToken"]);
      _user = await userRepo.getCurrentUser();
      authStateChanges.notify();
    } else {
      log("Error: postSignin (${response.statusCode})");
      throw Exception("로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.");
    }
  }

  /// 서버는 인증된 본인 세션만 로그아웃시킨다 (Bearer 토큰 필수).
  Future<void> postSignOut() async {
    final uri = Env.apiUri("$basepath/sign-out");

    try {
      final response = await requestWithRetry(
        (accessToken) => http.post(
          uri,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken",
          },
        ),
      );
      if (!(response.statusCode >= 200 && response.statusCode < 300)) {
        log("Error: postSignOut (${response.statusCode})");
      }
    } finally {
      // 서버 응답과 무관하게 로컬 세션은 항상 정리한다
      await _clearSession();
    }
  }

  Future<bool> checkEmail(String email) async {
    log("checkEmail");
    final Map<String, dynamic> queryParams = {"email": email};
    final uri = Env.apiUri("$basepath/check-email", queryParams);

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );
    log("${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body)["success"] == true;
    } else {
      log("Error: checkEmail");
      return false;
    }
  }

  Future<bool> checkNickname(String nickname) async {
    final Map<String, dynamic> queryParams = {"nickname": nickname};
    final uri = Env.apiUri("$basepath/check-nickname", queryParams);

    final response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    log("${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body)["success"] == true;
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
    // deleteAll은 다른 secure storage 키까지 지우므로 토큰만 명시적으로 삭제한다
    await Future.wait([
      _secureStorage.delete(key: "accessToken"),
      _secureStorage.delete(key: "refreshToken"),
    ]);
  }

  static Future<void> _clearSession() async {
    await tokensClear();
    _user = null;
    authStateChanges.notify();
  }

  static Future<bool> postReissue() async {
    final refreshToken = await _secureStorage.read(key: "refreshToken");
    if (refreshToken == null) {
      return false;
    }

    final uri = Env.apiUri("/api/v1/auth/reissue");

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      log("postReissue: ${response.statusCode}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final resBody = jsonDecode(response.body);
        final data = resBody["data"];
        await tokenSaves(data["accessToken"], data["refreshToken"]);
        return resBody["success"] == true;
      } else {
        log("Error: postReissue (${response.statusCode})");
        return false;
      }
    } catch (e) {
      log("Error: postReissue ($e)");
      return false;
    }
  }

  /// 동시 401 발생 시 재발급을 한 번만 수행하도록 in-flight Future를 공유한다.
  /// (리프레시 토큰 회전 방식에서는 중복 재발급이 세션 무효화로 이어진다)
  static Future<bool>? _reissueInFlight;

  static Future<bool> _reissueOnce() {
    final inFlight = _reissueInFlight;
    if (inFlight != null) return inFlight;

    final future = postReissue().whenComplete(() => _reissueInFlight = null);
    _reissueInFlight = future;
    return future;
  }

  static Future<http.Response> requestWithRetry(TokenFunction request) async {
    final accessToken = await _secureStorage.read(key: "accessToken");
    if (accessToken == null) {
      throw Exception("No access token.");
    }
    final response = await request(accessToken);
    if (response.statusCode != 401) {
      return response;
    }

    final reissued = await _reissueOnce();
    final newAccessToken = await _secureStorage.read(key: "accessToken");
    if (!reissued || newAccessToken == null) {
      // 재발급 실패 = 세션 만료. 토큰을 정리하고 로그아웃 상태를 알린다.
      await _clearSession();
      throw Exception("세션이 만료되었습니다. 다시 로그인해주세요.");
    }
    return await request(newAccessToken);
  }

  /// 로그인 상태면 Bearer 토큰을 붙이고, 아니면 익명으로 요청한다 (공개 API용)
  static Future<http.Response> requestWithOptionalAuth(
    TokenFunction request,
    Future<http.Response> Function() anonymousRequest,
  ) async {
    final accessToken = await _secureStorage.read(key: "accessToken");
    if (accessToken == null) {
      return anonymousRequest();
    }
    try {
      return await requestWithRetry(request);
    } catch (e) {
      // 세션 만료 등으로 인증 요청이 불가하면 익명으로 폴백한다
      log("requestWithOptionalAuth: 인증 요청 실패, 익명으로 폴백 ($e)");
      return anonymousRequest();
    }
  }
}

final authRepo = Provider((ref) => AuthenticationRepository());
