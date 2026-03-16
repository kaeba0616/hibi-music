import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';

class SignUpViewmodel extends AsyncNotifier<void> {
  late final AuthenticationRepository _authRepo;
  @override
  FutureOr<void> build() {
    _authRepo = ref.read(authRepo);
  }

  Future<bool> signUp() async {
    state = const AsyncValue.loading();
    final form = ref.read(signUpForm);
    bool chk = false;
    state = await AsyncValue.guard(() async {
      chk = await _authRepo.postLocalSignup(
        form["email"],
        form["password"],
        form["nickname"],
      );
    });
    return chk;
  }

  Future<bool> checkEmail() async {
    state = const AsyncValue.loading();
    final form = ref.read(signUpForm);
    bool chk = false;
    state = await AsyncValue.guard(() async {
      chk = await _authRepo.checkEmail(form["email"]);
    });
    return chk;
  }

  Future<bool> checkNickname() async {
    state = AsyncValue.loading();
    final form = ref.read(signUpForm);
    bool chk = false;
    state = await AsyncValue.guard(() async {
      chk = await _authRepo.checkNickname(form["nickname"]);
    });
    return chk;
  }
}

final signUpForm = StateProvider((ref) => {});

final signUpProvider = AsyncNotifierProvider<SignUpViewmodel, void>(
  () => SignUpViewmodel(),
);
