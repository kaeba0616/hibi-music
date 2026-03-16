import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/main-screen/views/main_navigation_view.dart';
import 'package:hidi/features/onboarding/models/social_provider.dart';
import 'package:hidi/features/onboarding/mocks/onboarding_mock.dart';

/// 소셜 로그인 상태
enum SocialLoginStatus { idle, loading, success, error }

class SocialLoginState {
  final SocialLoginStatus status;
  final SocialProvider? provider;
  final String? errorMessage;
  final bool isNewUser;

  const SocialLoginState({
    this.status = SocialLoginStatus.idle,
    this.provider,
    this.errorMessage,
    this.isNewUser = false,
  });

  SocialLoginState copyWith({
    SocialLoginStatus? status,
    SocialProvider? provider,
    String? errorMessage,
    bool? isNewUser,
  }) {
    return SocialLoginState(
      status: status ?? this.status,
      provider: provider ?? this.provider,
      errorMessage: errorMessage,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

class OnboardingViewModel extends StateNotifier<SocialLoginState> {
  OnboardingViewModel() : super(const SocialLoginState());

  Future<void> socialLogin(
    BuildContext context,
    SocialProvider provider,
  ) async {
    state = SocialLoginState(
      status: SocialLoginStatus.loading,
      provider: provider,
    );

    try {
      // Mock: 소셜 로그인 시뮬레이션
      final result = await mockSocialLogin();

      final isNewUser = result['data']['isNewUser'] as bool;

      state = state.copyWith(
        status: SocialLoginStatus.success,
        isNewUser: isNewUser,
      );

      if (isNewUser) {
        // 신규 회원 → 닉네임 설정 (기존 회원가입 플로우의 nickname_view 재활용)
        log('Social login: new user, redirect to nickname setup');
        if (context.mounted) {
          context.go('/sign-up'); // 닉네임 설정으로 이동
        }
      } else {
        // 기존 회원 → 메인 화면
        log('Social login: existing user, redirect to main');
        if (context.mounted) {
          context.go('/${MainNavigationView.initialTab}');
        }
      }
    } catch (e) {
      log('Social login error: $e');
      state = SocialLoginState(
        status: SocialLoginStatus.error,
        provider: provider,
        errorMessage: e.toString(),
      );
    }
  }

  void cancelLogin() {
    state = const SocialLoginState();
  }

  void clearError() {
    state = const SocialLoginState();
  }
}

final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, SocialLoginState>(
  (ref) => OnboardingViewModel(),
);
