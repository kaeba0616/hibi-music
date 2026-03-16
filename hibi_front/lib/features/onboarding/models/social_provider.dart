/// 소셜 로그인 제공자 Enum
enum SocialProvider {
  kakao(
    label: '카카오',
    color: 0xFFFEE500,
    textColor: 0xFF191919,
    iconText: 'K',
  ),
  google(
    label: '구글',
    color: 0xFFFFFFFF,
    textColor: 0xFF757575,
    iconText: 'G',
  ),
  naver(
    label: '네이버',
    color: 0xFF03C75A,
    textColor: 0xFFFFFFFF,
    iconText: 'N',
  );

  final String label;
  final int color;
  final int textColor;
  final String iconText;

  const SocialProvider({
    required this.label,
    required this.color,
    required this.textColor,
    required this.iconText,
  });
}
