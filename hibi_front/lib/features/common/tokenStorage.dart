// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class TokenStorage {
//   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//   static const String _accessTokenKey = 'access_token';
//   static const String _refreshTokenKey = 'refresh_token';

//   Future<void> saveTokens(String accessToken, String refreshToken) async {
//     await _secureStorage.write(
//       key: _accessTokenKey,
//       value: accessToken,
//       iOptions: _getIOSOptions(),
//       aOptions: _getAndroidOptions(),
//     );
//     await _secureStorage.write(
//       key: _refreshTokenKey,
//       value: refreshToken,
//       iOptions: _getIOSOptions(),
//       aOptions: _getAndroidOptions(),
//     );
//   }

//   Future<String?> getAccessToken() async {
//     return await _secureStorage.read(
//       key: _accessTokenKey,
//       iOptions: _getIOSOptions(),
//       aOptions: _getAndroidOptions(),
//     );
//   }

//   Future<String?> getRefreshToken() async {
//     return await _secureStorage.read(
//       key: _refreshTokenKey,
//       iOptions: _getIOSOptions(),
//       aOptions: _getAndroidOptions(),
//     );
//   }

//   Future<void> deleteTokens() async {
//     await _secureStorage.delete(
//       key: _accessTokenKey,
//       iOptions: _getIOSOptions(),
//       aOptions: _getAndroidOptions(),
//     );
//     await _secureStorage.delete(
//       key: _refreshTokenKey,
//       iOptions: _getIOSOptions(),
//       aOptions: _getAndroidOptions(),
//     );
//   }

//   IOSOptions _getIOSOptions() => IOSOptions(
//         accessibility: KeychainAccessibility.unlocked,
//         synchronizable: false, // Disable iCloud sync for tokens
//       );

//   AndroidOptions _getAndroidOptions() => const AndroidOptions(
//         encryptedSharedPreferences: true,
//       );
// }
