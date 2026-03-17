import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/constants/sizes.dart';
import 'package:hidi/features/authentication/mocks/verification_mock.dart';
import 'package:hidi/features/authentication/viewmodels/signup_view_model.dart';
import 'package:hidi/features/authentication/views/verification_code_view.dart';

/// EV-01: 이메일 입력 화면 (F14 강화)
class EmailView extends ConsumerStatefulWidget {
  const EmailView({super.key});

  @override
  ConsumerState<EmailView> createState() => _EmailViewState();
}

class _EmailViewState extends ConsumerState<EmailView> {
  final _emailController = TextEditingController();
  String _email = "";
  bool _isButtonDisable = true;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _isEmailValid() {
    if (_email.isEmpty) return null;
    final regExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return regExp.hasMatch(_email) ? null : '올바른 이메일 형식이 아닙니다';
  }

  void _isButtonValid() {
    setState(() {
      _email = _emailController.text;
      _isButtonDisable = _email.isEmpty || _isEmailValid() != null;
      _errorText = _isEmailValid();
    });
  }

  Future<void> _onSubmit() async {
    if (_isButtonDisable || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // 1. 이메일 중복 체크
    final state = ref.read(signUpForm.notifier).state;
    ref.read(signUpForm.notifier).state = {...state, "email": _email};
    final emailAvailable = await ref.read(signUpProvider.notifier).checkEmail();

    if (!emailAvailable) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorText = '이미 가입된 이메일입니다';
        });
      }
      return;
    }

    // 2. 인증번호 발송
    log('Sending verification code to $_email');
    await mockSendVerificationCode(_email);

    if (mounted) {
      setState(() => _isLoading = false);
      // 3. 인증번호 확인 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationCodeView(email: _email),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HIBI')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.size32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Sizes.size24),
            const Text(
              '이메일을 입력해주세요',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: Sizes.size4),
            Text(
              '인증번호를 보내드립니다',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: Sizes.size24),

            // 이메일 입력
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => _isButtonValid(),
              onSubmitted: (_) => _onSubmit(),
              decoration: InputDecoration(
                hintText: '이메일 주소',
                errorText: _errorText,
                prefixIcon: const Icon(Icons.email_outlined),
                suffixIcon: _email.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _emailController.clear();
                          _isButtonValid();
                        },
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
            const SizedBox(height: Sizes.size24),

            // 인증번호 받기 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    !_isButtonDisable && !_isLoading ? _onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade400,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                  ),
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
                        '인증번호 받기',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
