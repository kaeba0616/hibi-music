import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/onboarding/models/social_provider.dart';
import 'package:hidi/features/onboarding/mocks/onboarding_mock.dart';
import 'package:hidi/features/onboarding/repos/google_auth_service.dart';
import 'package:http/http.dart' as http;

class SocialAuthRepository {
  final basehost = Env.basehost;
  final basepath = '/api/v1/auth';
  final bool useMock;
  final GoogleAuthService _googleAuthService;

  SocialAuthRepository({
    this.useMock = false,
    GoogleAuthService? googleAuthService,
  }) : _googleAuthService = googleAuthService ?? GoogleAuthService();

  /// 소셜 로그인 전체 흐름: 제공자 SDK로 토큰 발급 → 백엔드 검증/로그인.
  /// 반환: { success, message, data: { accessToken, refreshToken, memberId, roleType, isNewUser } }
  Future<Map<String, dynamic>> signInWithProvider(
    SocialProvider provider,
  ) async {
    if (useMock) {
      return mockSocialLogin();
    }

    switch (provider) {
      case SocialProvider.google:
        final googleAccessToken = await _googleAuthService.getAccessToken();
        return postSocialLogin(
          provider: provider,
          socialAccessToken: googleAccessToken,
        );
      case SocialProvider.kakao:
      case SocialProvider.naver:
        throw Exception('${provider.label} 로그인은 아직 지원되지 않습니다.');
    }
  }

  /// 소셜 로그인 API 호출
  /// 반환: 응답 전체 { success, message, data: { accessToken, refreshToken, memberId, roleType, isNewUser } }
  Future<Map<String, dynamic>> postSocialLogin({
    required SocialProvider provider,
    required String socialAccessToken,
    String? nickname,
  }) async {
    if (useMock) {
      return mockSocialLogin();
    }

    final uri = Env.apiUri('$basepath/social-login');

    final String providerName = provider.name.toUpperCase();
    final Map<String, dynamic> body = {
      'provider': providerName,
      'accessToken': socialAccessToken,
      if (nickname != null) 'nickname': nickname,
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    log('Social login response: ${response.statusCode}');
    final resBody = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return resBody;
    } else {
      throw Exception(resBody['message'] ?? '소셜 로그인에 실패했습니다.');
    }
  }
}

final socialAuthRepoProvider = Provider<SocialAuthRepository>((ref) {
  // 실제 소셜 SDK 연동 전까지 기본값은 mock (다른 repo들과 동일한 기본값)
  const useMock = Env.useMock;
  return SocialAuthRepository(useMock: useMock);
});
