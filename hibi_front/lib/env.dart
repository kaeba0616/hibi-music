class Env {
  /// API 서버 주소. 전체 URL 형식 권장 (예: https://api.hibi.app, http://localhost:8080)
  /// 스킴 없이 host:port만 주면 http로 간주한다 (로컬 개발 하위호환).
  static const String rawBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// 하위호환용 host (스킴 제외). 미설정 시 빈 문자열.
  static const basehost = rawBaseUrl;

  static Uri get baseUri {
    if (rawBaseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL이 설정되지 않았습니다. '
        '--dart-define=API_BASE_URL=https://api.example.com 형식으로 실행하거나 '
        '--dart-define=USE_MOCK=true 로 mock 모드를 사용하세요.',
      );
    }
    final normalized =
        rawBaseUrl.contains('://') ? rawBaseUrl : 'http://$rawBaseUrl';
    return Uri.parse(normalized);
  }

  /// 실제 API 연동 전까지 기본값은 mock 모드
  static const bool useMock =
      String.fromEnvironment('USE_MOCK', defaultValue: 'true') == 'true';

  /// API 요청 URI 생성. API_BASE_URL의 스킴(https 포함)을 그대로 따른다.
  static Uri apiUri(String path, [Map<String, dynamic>? queryParameters]) {
    return baseUri.replace(path: path, queryParameters: queryParameters);
  }
}
