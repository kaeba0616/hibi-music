/// F13: 온보딩 & 소셜 로그인 Mock 데이터

/// Mock 소셜 로그인 응답 (성공 - 기존 회원)
final Map<String, dynamic> mockSocialLoginExistingUser = {
  'success': true,
  'data': {
    'accessToken': 'mock_access_token_social_12345',
    'refreshToken': 'mock_refresh_token_social_67890',
    'isNewUser': false,
  },
};

/// Mock 소셜 로그인 응답 (성공 - 신규 회원)
final Map<String, dynamic> mockSocialLoginNewUser = {
  'success': true,
  'data': {
    'accessToken': 'mock_access_token_social_new_12345',
    'refreshToken': 'mock_refresh_token_social_new_67890',
    'isNewUser': true,
  },
};

/// Mock 소셜 로그인 지연 시뮬레이션
Future<Map<String, dynamic>> mockSocialLogin({
  bool isNewUser = false,
  bool shouldFail = false,
}) async {
  await Future.delayed(const Duration(seconds: 2));

  if (shouldFail) {
    throw Exception('소셜 로그인에 실패했습니다. 다시 시도해주세요.');
  }

  return isNewUser ? mockSocialLoginNewUser : mockSocialLoginExistingUser;
}
