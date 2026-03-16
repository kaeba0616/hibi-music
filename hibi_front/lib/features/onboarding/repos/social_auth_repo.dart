import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/env.dart';
import 'package:hidi/features/onboarding/models/social_provider.dart';
import 'package:hidi/features/onboarding/mocks/onboarding_mock.dart';
import 'package:http/http.dart' as http;

class SocialAuthRepository {
  final basehost = Env.basehost;
  final basepath = '/api/v1/auth';
  final bool useMock;

  SocialAuthRepository({this.useMock = false});

  /// 소셜 로그인 API 호출
  /// 반환: { accessToken, refreshToken, memberId, roleType, isNewUser }
  Future<Map<String, dynamic>> postSocialLogin({
    required SocialProvider provider,
    required String socialAccessToken,
    String? nickname,
  }) async {
    if (useMock) {
      return mockSocialLogin();
    }

    final uri = Uri.http(basehost, '$basepath/social-login');

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
  const useMock = String.fromEnvironment('USE_MOCK', defaultValue: 'false') == 'true';
  return SocialAuthRepository(useMock: useMock);
});
