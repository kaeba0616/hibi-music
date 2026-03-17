/// F14: 이메일 인증 Mock 데이터

/// Mock 인증번호 발송 (항상 성공, 1초 딜레이)
Future<bool> mockSendVerificationCode(String email) async {
  await Future.delayed(const Duration(seconds: 1));
  return true;
}

/// Mock 인증번호 확인 ("123456" 입력 시 성공)
Future<bool> mockCheckVerificationCode(String email, String code) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return code == '123456';
}
