import 'package:google_sign_in/google_sign_in.dart';

/// 구글 로그인 SDK 래퍼.
/// 백엔드 검증에 필요한 구글 OAuth 액세스 토큰을 발급받는다.
///
/// 플랫폼 설정:
/// - Android: Firebase/GCP 콘솔의 Android OAuth 클라이언트 등록 (SHA-1 포함)
/// - iOS: GoogleService-Info.plist 또는 Info.plist의 GIDClientID
/// - 서버 검증용 클라이언트 ID는 --dart-define=GOOGLE_SERVER_CLIENT_ID=... 로 주입 (선택)
class GoogleAuthService {
  static const List<String> _scopes = ['email', 'profile'];
  static const String _serverClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
    );
    _initialized = true;
  }

  /// 구글 계정 선택 → 스코프 승인 → 액세스 토큰 반환.
  /// 사용자가 취소하면 GoogleSignInException이 전파된다.
  Future<String> getAccessToken() async {
    await _ensureInitialized();

    final account =
        await GoogleSignIn.instance.authenticate(scopeHint: _scopes);

    final authorization = await account.authorizationClient
            .authorizationForScopes(_scopes) ??
        await account.authorizationClient.authorizeScopes(_scopes);

    return authorization.accessToken;
  }
}
