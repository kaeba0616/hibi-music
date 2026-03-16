import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/constants/images.dart';
import 'package:hidi/features/authentication/views/email_view.dart';
import 'package:hidi/features/authentication/views/login_view.dart';

class SignUpView extends ConsumerWidget {
  static const String routeName = 'signup';
  static const String routeURL = '/sign-up';

  const SignUpView({super.key});

  void _onLocalTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmailView()),
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
                      onPressed: () => _onLocalTap(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("이메일 회원가입"),
                    ),
                    TextButton(
                      onPressed: () => context.go(LoginView.routeURL),
                      child: Text("login"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: 1,
              child: SizedBox(
                height: 300,
                width: 300,
                child: Image.asset(
                  Images.hibiUnbackground,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
