import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  log('API Base URL: $apiBaseUrl');
  final _authRepo = AuthenticationRepository();
  await _authRepo.init();
  runApp(
    ProviderScope(
      overrides: [authRepo.overrideWithValue(_authRepo)],
      child: Hidi(),
    ),
  );
}

class Hidi extends ConsumerWidget {
  const Hidi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.read(routerProvider),
      title: 'Hibi',
    );
  }
}
