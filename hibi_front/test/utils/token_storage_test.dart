import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/utils/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenStorage (web 폴백 경로)', () {
    late TokenStorage storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      // 웹에서는 flutter_secure_storage의 WebCrypto 구현이 OperationError를
      // 던지는 문제가 있어 SharedPreferences로 폴백한다
      storage = TokenStorage(isWeb: true);
    });

    test('write 후 read로 같은 값을 돌려받는다', () async {
      await storage.write(key: 'accessToken', value: 'token-123');

      expect(await storage.read(key: 'accessToken'), 'token-123');
    });

    test('없는 키는 null을 반환한다', () async {
      expect(await storage.read(key: 'missing'), isNull);
    });

    test('delete 후에는 null을 반환한다', () async {
      await storage.write(key: 'refreshToken', value: 'rt-456');
      await storage.delete(key: 'refreshToken');

      expect(await storage.read(key: 'refreshToken'), isNull);
    });
  });
}
