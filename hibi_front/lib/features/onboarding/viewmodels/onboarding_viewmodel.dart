import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/main-screen/views/main_navigation_view.dart';
import 'package:hidi/features/onboarding/models/social_provider.dart';
import 'package:hidi/features/onboarding/repos/social_auth_repo.dart';

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
  final SocialAuthRepository _repo;
  static const _storage = FlutterSecureStorage();

  OnboardingViewModel(this._repo) : super(const SocialLoginState());

  Future<void> socialLogin(
    BuildContext context,
    SocialProvider provider,
  ) async {
    state = SocialLoginState(
      status: SocialLoginStatus.loading,
      provider: provider,
    );

    try {
      final result = await _repo.postSocialLogin(
        provider: provider,
        socialAccessToken: 'mock_social_token_${provider.name}',
      );

      final data = result['data'] as Map<String, dynamic>;
      final isNewUser = data['isNewUser'] as bool;

      // 토큰 저장
      if (data['accessToken'] != null) {
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);
      }

      state = state.copyWith(
        status: SocialLoginStatus.success,
        isNewUser: isNewUser,
      );

      if (isNewUser) {
        log('Social login: new user, redirect to nickname setup');
        if (context.mounted) {
          context.go('/sign-up');
        }
      } else {
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
    StateNotifierProvider<OnboardingViewModel, SocialLoginState>((ref) {
  final repo = ref.watch(socialAuthRepoProvider);
  return OnboardingViewModel(repo);
});
