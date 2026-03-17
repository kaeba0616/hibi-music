import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hidi/constants/sizes.dart';
import 'package:hidi/features/authentication/viewmodels/signup_view_model.dart';
import 'package:hidi/features/authentication/views/nickname_view.dart';

/// EV-03: 비밀번호 설정 화면 (F14 강화 - 실시간 규칙 체크)
class PasswordView extends ConsumerStatefulWidget {
  const PasswordView({super.key});

  @override
  ConsumerState<PasswordView> createState() => _PasswordViewState();
}

class _PasswordViewState extends ConsumerState<PasswordView> {
  final _passwordController1 = TextEditingController();
  final _passwordController2 = TextEditingController();

  String _password1 = "";
  String _password2 = "";
  bool _isObscure1 = true;
  bool _isObscure2 = true;

  @override
  void dispose() {
    _passwordController1.dispose();
    _passwordController2.dispose();
    super.dispose();
  }

  // 비밀번호 규칙 체크 (F14)
  bool get _hasMinLength => _password1.length >= 8;
  bool get _hasLetter => RegExp(r'[a-zA-Z]').hasMatch(_password1);
  bool get _hasDigit => RegExp(r'[0-9]').hasMatch(_password1);
  bool get _hasSpecialChar =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]').hasMatch(_password1);
  bool get _passwordsMatch =>
      _password1.isNotEmpty &&
      _password2.isNotEmpty &&
      _password1 == _password2;

  bool get _allRulesPassed =>
      _hasMinLength &&
      _hasLetter &&
      _hasDigit &&
      _hasSpecialChar &&
      _passwordsMatch;

  void _onSubmit() {
    if (!_allRulesPassed) return;
    final state = ref.read(signUpForm.notifier).state;
    ref.read(signUpForm.notifier).state = {...state, "password": _password1};
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NicknameView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HIBI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.size32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Sizes.size24),
            const Text(
              '비밀번호를 설정해주세요',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: Sizes.size24),

            // 비밀번호 입력
            TextField(
              controller: _passwordController1,
              obscureText: _isObscure1,
              onChanged: (value) => setState(() => _password1 = value),
              decoration: InputDecoration(
                hintText: '비밀번호',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _isObscure1 = !_isObscure1),
                  icon: FaIcon(
                    _isObscure1
                        ? FontAwesomeIcons.eye
                        : FontAwesomeIcons.eyeSlash,
                    size: 18,
                  ),
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
            const SizedBox(height: Sizes.size16),

            // 비밀번호 확인
            TextField(
              controller: _passwordController2,
              obscureText: _isObscure2,
              onChanged: (value) => setState(() => _password2 = value),
              onSubmitted: (_) => _onSubmit(),
              decoration: InputDecoration(
                hintText: '비밀번호 확인',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _isObscure2 = !_isObscure2),
                  icon: FaIcon(
                    _isObscure2
                        ? FontAwesomeIcons.eye
                        : FontAwesomeIcons.eyeSlash,
                    size: 18,
                  ),
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
            const SizedBox(height: Sizes.size20),

            // 비밀번호 규칙 체크리스트 (F14)
            Text(
              '비밀번호 규칙:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: Sizes.size8),
            _buildRuleItem('8글자 이상', _hasMinLength),
            _buildRuleItem('영문 포함', _hasLetter),
            _buildRuleItem('숫자 포함', _hasDigit),
            _buildRuleItem('특수기호 포함', _hasSpecialChar),
            _buildRuleItem(
              '비밀번호 일치',
              _passwordsMatch,
              showWhenEmpty: _password2.isNotEmpty,
            ),
            const SizedBox(height: Sizes.size24),

            // 다음 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _allRulesPassed ? _onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade400,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                  ),
                ),
                child: const Text(
                  '다음',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: Sizes.size32),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String label, bool passed,
      {bool showWhenEmpty = true}) {
    if (!showWhenEmpty && _password1.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(Icons.circle_outlined, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
          ],
        ),
      );
    }

    final color = _password1.isEmpty
        ? Colors.grey.shade400
        : passed
            ? Colors.green
            : Colors.red;
    final icon = _password1.isEmpty
        ? Icons.circle_outlined
        : passed
            ? Icons.check_circle
            : Icons.cancel;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }
}
