import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/constants/images.dart';
import 'package:hidi/constants/sizes.dart';
import 'package:hidi/features/authentication/viewmodels/login_view_model.dart';
import 'package:hidi/features/authentication/views/sign_up_view.dart';
import 'package:hidi/features/onboarding/models/social_provider.dart';
import 'package:hidi/features/onboarding/views/social_auth_waiting_view.dart';
import 'package:hidi/features/onboarding/widgets/social_login_button.dart';

/// OB-02: 로그인 화면 (이메일 + 소셜 로그인 통합)
class LoginView extends ConsumerStatefulWidget {
  static const routeName = "login";
  static const routeURL = "/login";

  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  void _onSubmit() async {
    if (!_isFormValid || _isLoading) return;

    setState(() => _isLoading = true);

    final state = ref.read(loginForm.notifier).state;
    ref.read(loginForm.notifier).state = {
      ...state,
      "email": _emailController.text,
      "password": _passwordController.text,
    };
    await ref.read(loginProvider.notifier).signin(context);

    if (mounted) setState(() => _isLoading = false);
  }

  void _onSocialTap(SocialProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SocialAuthWaitingView(provider: provider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HIBI'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.size32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Sizes.size24),

              // 로고
              Center(
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset(
                    Images.hibiUnbackground,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: Sizes.size32),

              // 이메일 입력
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '이메일',
                  prefixIcon: const Icon(Icons.email_outlined),
                  suffixIcon: _emailController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _emailController.clear();
                            setState(() {});
                          },
                          child: const Icon(Icons.clear, size: 20),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: Sizes.size16),

              // 비밀번호 입력
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _onSubmit(),
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_passwordController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _passwordController.clear();
                            setState(() {});
                          },
                          child: const Icon(Icons.clear, size: 20),
                        ),
                      IconButton(
                        onPressed: () =>
                            setState(() => _isObscure = !_isObscure),
                        icon: FaIcon(
                          _isObscure
                              ? FontAwesomeIcons.eye
                              : FontAwesomeIcons.eyeSlash,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: Sizes.size24),

              // 로그인 버튼
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isFormValid && !_isLoading ? _onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade400,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Sizes.size8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: Sizes.size32),

              // 소셜 구분선
              const SocialDivider(text: '또는'),
              const SizedBox(height: Sizes.size20),

              // 소셜 로그인 버튼
              SocialLoginButtonRow(onSocialTap: _onSocialTap),
              const SizedBox(height: Sizes.size32),

              // 회원가입 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '계정이 없으신가요? ',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(SignUpView.routeURL),
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                        color: Colors.orange.shade400,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sizes.size32),
            ],
          ),
        ),
      ),
    );
  }
}
