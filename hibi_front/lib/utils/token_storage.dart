import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 토큰 저장소.
///
/// - 모바일(Android/iOS): 네이티브 Keystore/Keychain 기반 flutter_secure_storage
/// - 웹: flutter_secure_storage의 WebCrypto 구현이 저장 직후 읽기에서
///   OperationError를 던지는 문제가 있어 SharedPreferences(localStorage)로 폴백.
///   웹 localStorage는 암호화되지 않으므로, 웹을 정식 지원하려면
///   httpOnly 쿠키 세션 등 별도 설계가 필요하다.
class TokenStorage {
  final bool isWeb;
  final FlutterSecureStorage _secure;

  TokenStorage({bool? isWeb, FlutterSecureStorage? secureStorage})
      : isWeb = isWeb ?? kIsWeb,
        _secure = secureStorage ?? const FlutterSecureStorage();

  Future<String?> read({required String key}) async {
    if (isWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefsKey(key));
    }
    return _secure.read(key: key);
  }

  Future<void> write({required String key, required String value}) async {
    if (isWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey(key), value);
      return;
    }
    await _secure.write(key: key, value: value);
  }

  Future<void> delete({required String key}) async {
    if (isWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey(key));
      return;
    }
    await _secure.delete(key: key);
  }

  String _prefsKey(String key) => 'token_storage.$key';
}
