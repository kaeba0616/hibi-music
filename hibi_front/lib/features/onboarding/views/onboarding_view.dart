import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/constants/images.dart';
import 'package:hidi/constants/sizes.dart';
import 'package:hidi/features/authentication/views/login_view.dart';
import 'package:hidi/features/authentication/views/sign_up_view.dart';
import 'package:hidi/features/main-screen/views/main_navigation_view.dart';
import 'package:hidi/features/onboarding/models/social_provider.dart';
import 'package:hidi/features/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:hidi/features/onboarding/views/social_auth_waiting_view.dart';
import 'package:hidi/features/onboarding/widgets/social_login_button.dart';

/// OB-01: 온보딩 화면
class OnboardingView extends ConsumerWidget {
  static const routeName = "onboarding";
  static const routeURL = "/onboarding";

  const OnboardingView({super.key});

  void _onBrowseTap(BuildContext context) {
    context.go('/${MainNavigationView.initialTab}');
  }

  void _onLoginTap(BuildContext context) {
    context.push(LoginView.routeURL);
  }

  void _onSignUpTap(BuildContext context) {
    context.push(SignUpView.routeURL);
  }

  void _onSocialTap(BuildContext context, SocialProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SocialAuthWaitingView(provider: provider),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.size32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 앱 로고
              SizedBox(
                height: 160,
                width: 160,
                child: Image.asset(
                  Images.hibiUnbackground,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: Sizes.size12),

              // 앱 소개 텍스트
              Text(
                '日々',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: Sizes.size4),
              Text(
                '매일 한 곡, 당신을 위한 JPOP',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade500,
                ),
              ),

              const Spacer(flex: 2),

              // 둘러보기 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _onBrowseTap(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Sizes.size8),
                    ),
                  ),
                  child: Text(
                    '둘러보기',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Sizes.size24),

              // 소셜 로그인 구분선
              const SocialDivider(),
              const SizedBox(height: Sizes.size20),

              // 소셜 로그인 버튼 (카카오, 구글, 네이버)
              SocialLoginButtonRow(
                onSocialTap: (provider) => _onSocialTap(context, provider),
              ),
              const SizedBox(height: Sizes.size24),

              // 이메일로 로그인 버튼
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _onLoginTap(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Sizes.size8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '이메일로 로그인',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: Sizes.size12),

              // 회원가입 텍스트 버튼
              TextButton(
                onPressed: () => _onSignUpTap(context),
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
