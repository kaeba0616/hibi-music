import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/onboarding/models/social_provider.dart';
import 'package:hidi/features/onboarding/viewmodels/onboarding_viewmodel.dart';

/// OB-03: 소셜 인증 대기 화면
class SocialAuthWaitingView extends ConsumerStatefulWidget {
  final SocialProvider provider;

  const SocialAuthWaitingView({
    super.key,
    required this.provider,
  });

  @override
  ConsumerState<SocialAuthWaitingView> createState() =>
      _SocialAuthWaitingViewState();
}

class _SocialAuthWaitingViewState
    extends ConsumerState<SocialAuthWaitingView> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 소셜 로그인 시작
    Future.microtask(() {
      ref.read(onboardingViewModelProvider.notifier).socialLogin(
            context,
            widget.provider,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);

    // 에러 발생 시 SnackBar 표시 후 뒤로
    ref.listen<SocialLoginState>(onboardingViewModelProvider, (prev, next) {
      if (next.status == SocialLoginStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            action: SnackBarAction(
              label: '재시도',
              onPressed: () {
                ref.read(onboardingViewModelProvider.notifier).socialLogin(
                      context,
                      widget.provider,
                    );
              },
            ),
          ),
        );
        // 에러 후 이전 화면으로 복귀
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) Navigator.pop(context);
        });
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 소셜 서비스 로고
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(widget.provider.color),
                  shape: BoxShape.circle,
                  border: widget.provider == SocialProvider.google
                      ? Border.all(color: Colors.grey.shade300, width: 1)
                      : null,
                ),
                child: Center(
                  child: Text(
                    widget.provider.iconText,
                    style: TextStyle(
                      color: Color(widget.provider.textColor),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 안내 텍스트
              Text(
                '${widget.provider.label}으로',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '로그인 중입니다...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 32),

              // 로딩 인디케이터
              if (state.status == SocialLoginStatus.loading)
                const CircularProgressIndicator(),

              // 에러 상태
              if (state.status == SocialLoginStatus.error)
                Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade400,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '로그인에 실패했습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 48),

              // 취소 버튼
              TextButton(
                onPressed: () {
                  ref.read(onboardingViewModelProvider.notifier).cancelLogin();
                  Navigator.pop(context);
                },
                child: Text(
                  '취소',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
