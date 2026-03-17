import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/onboarding/models/social_provider.dart';
import 'package:hidi/features/onboarding/mocks/onboarding_mock.dart';

void main() {
  group('SocialProvider', () {
    test('3개 소셜 제공자가 있음 (카카오, 구글, 네이버)', () {
      expect(SocialProvider.values.length, 3);
      expect(SocialProvider.kakao.label, '카카오');
      expect(SocialProvider.google.label, '구글');
      expect(SocialProvider.naver.label, '네이버');
    });

    test('각 제공자에 브랜드 컬러가 있음', () {
      expect(SocialProvider.kakao.color, 0xFFFEE500);
      expect(SocialProvider.google.color, 0xFFFFFFFF);
      expect(SocialProvider.naver.color, 0xFF03C75A);
    });

    test('각 제공자에 아이콘 텍스트가 있음', () {
      expect(SocialProvider.kakao.iconText, 'K');
      expect(SocialProvider.google.iconText, 'G');
      expect(SocialProvider.naver.iconText, 'N');
    });
  });

  group('Onboarding Mock', () {
    test('Mock 소셜 로그인이 성공 응답을 반환함', () async {
      final result = await mockSocialLogin();
      expect(result['success'], true);
      expect(result['data']['accessToken'], isNotEmpty);
      expect(result['data']['isNewUser'], isFalse);
    });

    test('Mock 소셜 로그인 (신규 회원)이 isNewUser=true 반환', () async {
      final result = await mockSocialLogin(isNewUser: true);
      expect(result['data']['isNewUser'], isTrue);
    });

    test('Mock 소셜 로그인 실패 시 예외 발생', () async {
      expect(
        () => mockSocialLogin(shouldFail: true),
        throwsException,
      );
    });
  });
}
