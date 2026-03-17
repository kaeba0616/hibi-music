import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/authentication/mocks/verification_mock.dart';

void main() {
  group('Verification Mock', () {
    test('인증번호 발송 Mock이 성공을 반환함', () async {
      final result = await mockSendVerificationCode('test@example.com');
      expect(result, isTrue);
    });

    test('올바른 인증번호(123456) 확인 시 성공', () async {
      final result =
          await mockCheckVerificationCode('test@example.com', '123456');
      expect(result, isTrue);
    });

    test('잘못된 인증번호 확인 시 실패', () async {
      final result =
          await mockCheckVerificationCode('test@example.com', '000000');
      expect(result, isFalse);
    });

    test('빈 인증번호 확인 시 실패', () async {
      final result =
          await mockCheckVerificationCode('test@example.com', '');
      expect(result, isFalse);
    });
  });

  group('Password Rules', () {
    test('8글자 이상 체크', () {
      expect('abcd1234!'.length >= 8, isTrue);
      expect('abc12!'.length >= 8, isFalse);
    });

    test('영문 포함 체크', () {
      expect(RegExp(r'[a-zA-Z]').hasMatch('abc123!'), isTrue);
      expect(RegExp(r'[a-zA-Z]').hasMatch('123456!'), isFalse);
    });

    test('숫자 포함 체크', () {
      expect(RegExp(r'[0-9]').hasMatch('abc123!'), isTrue);
      expect(RegExp(r'[0-9]').hasMatch('abcdef!'), isFalse);
    });

    test('특수기호 포함 체크', () {
      expect(
          RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch('abc123!'), isTrue);
      expect(
          RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch('abc12345'), isFalse);
    });
  });
}
