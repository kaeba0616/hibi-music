import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/authentication/views/login_view.dart';
import 'package:hidi/features/main-screen/views/main_navigation_view.dart';

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

    if (state.hasError) {
      log("${state.error}");
    } else {
      context.go("/${MainNavigationView.initialTab}");
    }
  }

  Future<void> signOut(BuildContext context, int uid) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepo.postSignOut(uid);
    });

    if (state.hasError) {
      log("${state.error}");
    } else {
      context.go(LoginView.routeURL);
    }
  }
}

final loginForm = StateProvider((ref) => {});

final loginProvider = AsyncNotifierProvider<LoginViewmodel, void>(
  () => LoginViewmodel(),
);
