import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/onboarding/views/onboarding_view.dart';
import 'package:hidi/features/onboarding/widgets/social_login_button.dart';

void main() {
  group('OnboardingView', () {
    Widget buildWidget() {
      return const ProviderScope(
        child: MaterialApp(home: OnboardingView()),
      );
    }

    testWidgets('로고와 앱 소개 텍스트가 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('日々'), findsOneWidget);
      expect(find.text('매일 한 곡, 당신을 위한 JPOP'), findsOneWidget);
    });

    testWidgets('둘러보기 버튼이 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('둘러보기'), findsOneWidget);
    });

    testWidgets('이메일로 로그인 버튼이 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('이메일로 로그인'), findsOneWidget);
    });

    testWidgets('회원가입 버튼이 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('회원가입'), findsOneWidget);
    });

    testWidgets('소셜 로그인 버튼 3개 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byType(SocialLoginButton), findsNWidgets(3));
      expect(find.text('K'), findsOneWidget); // 카카오
      expect(find.text('G'), findsOneWidget); // 구글
      expect(find.text('N'), findsOneWidget); // 네이버
    });

    testWidgets('소셜 구분선이 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('소셜 계정으로 시작'), findsOneWidget);
    });
  });
}
