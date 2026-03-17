import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/authentication/views/verification_code_view.dart';
import 'package:hidi/features/authentication/views/password_view.dart';

void main() {
  group('VerificationCodeView', () {
    Widget buildWidget() {
      return const ProviderScope(
        child: MaterialApp(
          home: VerificationCodeView(email: 'test@example.com'),
        ),
      );
    }

    testWidgets('이메일 주소가 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('안내 텍스트가 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('인증번호를 입력해주세요'), findsOneWidget);
    });

    testWidgets('6개 입력 필드가 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('타이머가 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('03:00'), findsOneWidget);
    });

    testWidgets('확인 버튼이 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('확인'), findsOneWidget);
    });

    testWidgets('인증번호 재발송 링크가 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('인증번호 재발송'), findsOneWidget);
    });
  });

  group('PasswordView 규칙 체크', () {
    Widget buildWidget() {
      return const ProviderScope(
        child: MaterialApp(home: PasswordView()),
      );
    }

    testWidgets('비밀번호 규칙 5개 항목이 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('8글자 이상'), findsOneWidget);
      expect(find.text('영문 포함'), findsOneWidget);
      expect(find.text('숫자 포함'), findsOneWidget);
      expect(find.text('특수기호 포함'), findsOneWidget);
      expect(find.text('비밀번호 일치'), findsOneWidget);
    });

    testWidgets('비밀번호 설정 안내 텍스트가 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('비밀번호를 설정해주세요'), findsOneWidget);
    });
  });
}
