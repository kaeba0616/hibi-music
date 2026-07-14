import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/authentication/views/email_view.dart';
import 'package:hidi/features/authentication/views/password_view.dart';
import 'package:hidi/features/authentication/views/verification_code_view.dart';

import '../../utils/test_app.dart';

class _FakeAuthRepo extends AuthenticationRepository {
  final bool emailAvailable;

  _FakeAuthRepo({this.emailAvailable = true});

  @override
  Future<bool> checkEmail(String email) async => emailAvailable;
}

void main() {
  group('EmailView', () {
    testWidgets('유효한 이메일 제출 시 인증 단계 없이 비밀번호 화면으로 이동한다', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const EmailView(),
          overrides: [authRepo.overrideWithValue(_FakeAuthRepo())],
        ),
      );

      await tester.enterText(find.byType(TextField), 'new@example.com');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byType(PasswordView), findsOneWidget);
      expect(find.byType(VerificationCodeView), findsNothing);
    });

    testWidgets('이미 가입된 이메일이면 에러를 표시하고 이동하지 않는다', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const EmailView(),
          overrides: [
            authRepo.overrideWithValue(_FakeAuthRepo(emailAvailable: false)),
          ],
        ),
      );

      await tester.enterText(find.byType(TextField), 'dup@example.com');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('이미 가입된 이메일입니다'), findsOneWidget);
      expect(find.byType(PasswordView), findsNothing);
    });
  });
}
