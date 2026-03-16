import 'package:flutter/material.dart';
import 'package:hidi/features/onboarding/models/social_provider.dart';

/// 소셜 로그인 원형 아이콘 버튼
class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onTap;
  final double size;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onTap,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Color(provider.color),
          shape: BoxShape.circle,
          border: provider == SocialProvider.google
              ? Border.all(color: Colors.grey.shade300, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            provider.iconText,
            style: TextStyle(
              color: Color(provider.textColor),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// 소셜 로그인 버튼 행 (카카오, 구글, 네이버)
class SocialLoginButtonRow extends StatelessWidget {
  final void Function(SocialProvider provider) onSocialTap;

  const SocialLoginButtonRow({
    super.key,
    required this.onSocialTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: SocialProvider.values.map((provider) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SocialLoginButton(
            provider: provider,
            onTap: () => onSocialTap(provider),
          ),
        );
      }).toList(),
    );
  }
}

/// "소셜 계정으로 시작" 구분선
class SocialDivider extends StatelessWidget {
  final String text;

  const SocialDivider({
    super.key,
    this.text = '소셜 계정으로 시작',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }
}
