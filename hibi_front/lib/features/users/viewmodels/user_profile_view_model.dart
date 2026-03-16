import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/authentication/views/login_view.dart';
import 'package:hidi/features/users/models/user.dart';
import 'package:hidi/features/users/repos/users_repos.dart';

class UserProfileViewModel extends AsyncNotifier<User> {
  late final UserRepository _userRepo;
  late final AuthenticationRepository _authRepo;
  @override
  FutureOr<User> build() async {
    _userRepo = ref.read(userRepo);
    _authRepo = ref.read(authRepo);
    if (_authRepo.isLoggedIn) {
      final user = await _userRepo.getCurrentUser();
      if (user != null) {
        return user;
      }
    }
    return User.empty();
  }

  Future<void> deleteCurrentUser(BuildContext context) async {
    state = AsyncValue.loading();
    await _userRepo.deleteCurrentUser(ref);
    if (state.hasError) {
      log("${state.error}");
    } else {
      context.go(LoginView.routeURL);
    }
  }

  Future<void> patchCurrentUser(
    BuildContext context,
    String nickname,
    String password,
  ) async {
    state = AsyncLoading();
    final success = await _userRepo.patchCurrentUser(nickname, password);
    state = AsyncValue.data(state.value!.copywith(nickname: nickname));
    if (success) {
      context.pop();
    }
  }
}

final userProfileProvider = AsyncNotifierProvider<UserProfileViewModel, User>(
  () => UserProfileViewModel(),
);
