import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/onboarding/models/social_provider.dart';
import 'package:hidi/features/onboarding/repos/social_auth_repo.dart';

void main() {
  group('SocialAuthRepository.signInWithProvider', () {
    test('Mock 모드에서는 실제 SDK 없이 mock 응답을 반환한다', () async {
      final repo = SocialAuthRepository(useMock: true);

      final result = await repo.signInWithProvider(SocialProvider.google);

      expect(result['success'], isTrue);
      expect(result['data']['accessToken'], isNotEmpty);
    });

    test('실제 모드에서 아직 연동되지 않은 제공자(kakao)는 예외를 던진다', () async {
      final repo = SocialAuthRepository(useMock: false);

      expect(
        () => repo.signInWithProvider(SocialProvider.kakao),
        throwsA(isA<Exception>()),
      );
    });

    test('실제 모드에서 아직 연동되지 않은 제공자(naver)는 예외를 던진다', () async {
      final repo = SocialAuthRepository(useMock: false);

      expect(
        () => repo.signInWithProvider(SocialProvider.naver),
        throwsA(isA<Exception>()),
      );
    });
  });
}
