import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/constants/images.dart';
import 'package:hidi/features/authentication/views/login_form_view.dart';
import 'package:hidi/features/authentication/views/sign_up_view.dart';

class LoginView extends ConsumerWidget {
  static const routeName = "login";
  static const routeURL = "/login";
  const LoginView({super.key});

  void _onLoginTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginFormView()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(""),
                Column(
                  children: [
                    TextButton(
                      onPressed: () => _onLoginTap(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("로그인"),
                    ),
                    TextButton(
                      onPressed: () => context.go(SignUpView.routeURL),
                      child: Text("signup"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 300,
              width: 300,
              child: Image.asset(
                Images.hibiUnbackground,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
