import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/main-screen/views/main_navigation_view.dart';
import 'package:hidi/features/onboarding/views/onboarding_view.dart';

class LoginViewmodel extends AsyncNotifier<void> {
  late final AuthenticationRepository _authRepo;

  @override
  FutureOr<void> build() {
    _authRepo = ref.read(authRepo);
  }

  Future<void> signin(BuildContext context) async {
    state = const AsyncValue.loading();
    final form = ref.read(loginForm);
    state = await AsyncValue.guard(() async {
      await _authRepo.postSignin(form["email"], form["password"]);
    });

    if (!context.mounted) return;
    if (state.hasError) {
      log("${state.error}");
      _showError(context, "로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.");
    } else {
      context.go("/${MainNavigationView.initialTab}");
    }
  }

  Future<void> signOut(BuildContext context, int uid) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepo.postSignOut(uid);
    });

    if (!context.mounted) return;
    if (state.hasError) {
      log("${state.error}");
      _showError(context, "로그아웃에 실패했습니다. 잠시 후 다시 시도해주세요.");
    } else {
      context.go(OnboardingView.routeURL);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

final loginForm = StateProvider((ref) => {});

final loginProvider = AsyncNotifierProvider<LoginViewmodel, void>(
  () => LoginViewmodel(),
);
