import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/constants/sizes.dart';
import 'package:hidi/features/authentication/mocks/verification_mock.dart';
import 'package:hidi/features/authentication/views/password_view.dart';

/// EV-02: 인증번호 확인 화면 (F14)
class VerificationCodeView extends ConsumerStatefulWidget {
  final String email;

  const VerificationCodeView({super.key, required this.email});

  @override
  ConsumerState<VerificationCodeView> createState() =>
      _VerificationCodeViewState();
}

class _VerificationCodeViewState extends ConsumerState<VerificationCodeView> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _remainingSeconds = 180; // 3분
  bool _isExpired = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _focusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 180;
    _isExpired = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _isExpired = true;
          timer.cancel();
        }
      });
    });
  }

  String get _timerText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _code => _controllers.map((c) => c.text).join();

  bool get _isCodeComplete => _code.length == 6;

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _onSubmit() async {
    if (!_isCodeComplete || _isLoading || _isExpired) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await mockCheckVerificationCode(widget.email, _code);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PasswordView()),
        );
      } else {
        setState(() {
          _errorMessage = '인증번호가 올바르지 않습니다';
          for (var c in _controllers) {
            c.clear();
          }
          _focusNodes[0].requestFocus();
        });
      }
    }
  }

  Future<void> _onResend() async {
    await mockSendVerificationCode(widget.email);
    if (mounted) {
      _startTimer();
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증번호가 재발송되었습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('HIBI')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.size32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Sizes.size24),
            const Text(
              '인증번호를 입력해주세요',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: Sizes.size8),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                children: [
                  TextSpan(
                    text: widget.email,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' 으로\n인증번호를 보냈습니다'),
                ],
              ),
            ),
            const SizedBox(height: Sizes.size32),

            // 6자리 입력 필드
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: colorScheme.primary, width: 2),
                      ),
                    ),
                    onChanged: (value) => _onDigitChanged(index, value),
                  ),
                );
              }),
            ),
            const SizedBox(height: Sizes.size16),

            // 타이머
            Center(
              child: Text(
                _isExpired ? '인증번호가 만료되었습니다' : _timerText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _isExpired || _remainingSeconds < 30
                      ? Colors.red
                      : Colors.grey.shade700,
                ),
              ),
            ),

            // 에러 메시지
            if (_errorMessage != null) ...[
              const SizedBox(height: Sizes.size8),
              Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ],
            const SizedBox(height: Sizes.size24),

            // 확인 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    _isCodeComplete && !_isLoading && !_isExpired
                        ? _onSubmit
                        : null,
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
                    : const Text('확인',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: Sizes.size16),

            // 재발송 링크
            Center(
              child: Column(
                children: [
                  Text(
                    '인증번호가 오지 않았나요?',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  TextButton(
                    onPressed: _onResend,
                    child: Text(
                      '인증번호 재발송',
                      style: TextStyle(
                        color: Colors.orange.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
