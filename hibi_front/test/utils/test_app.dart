import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트용 앱 래퍼
///
/// Provider override와 함께 Widget을 테스트할 때 사용합니다.
///
/// 사용 예시:
/// ```dart
/// await tester.pumpWidget(
///   createTestApp(
///     child: MyWidget(),
///     overrides: [
///       myRepoProvider.overrideWithValue(mockRepo),
///     ],
///   ),
/// );
/// ```
Widget createTestApp({
  required Widget child,
  List<Override>? overrides,
  ThemeData? theme,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: child,
    ),
  );
}

/// Scaffold로 감싼 테스트 앱 래퍼
///
/// SnackBar, BottomSheet 등을 테스트할 때 사용합니다.
Widget createTestAppWithScaffold({
  required Widget child,
  List<Override>? overrides,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

/// 테스트용 네비게이터 래퍼
///
/// Navigation을 테스트할 때 사용합니다.
Widget createTestAppWithNavigator({
  required Widget child,
  List<Override>? overrides,
  List<Route<dynamic>> Function(RouteSettings)? onGenerateRoute,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: child,
      onGenerateRoute: onGenerateRoute != null
          ? (settings) => onGenerateRoute(settings).first
          : null,
    ),
  );
}

/// WidgetTester 확장 메서드
extension WidgetTesterExtensions on WidgetTester {
  /// 로딩이 완료될 때까지 대기
  Future<void> waitForLoading({Duration timeout = const Duration(seconds: 5)}) async {
    await pumpAndSettle(timeout);
  }

  /// SnackBar 메시지 확인
  void expectSnackBar(String message) {
    expect(find.text(message), findsOneWidget);
  }

  /// 버튼이 비활성화되었는지 확인
  void expectButtonDisabled(Finder buttonFinder) {
    final button = widget<ElevatedButton>(buttonFinder);
    expect(button.onPressed, isNull);
  }

  /// 버튼이 활성화되었는지 확인
  void expectButtonEnabled(Finder buttonFinder) {
    final button = widget<ElevatedButton>(buttonFinder);
    expect(button.onPressed, isNotNull);
  }
}

/// 테스트용 Mock 데이터
class TestData {
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'password123';
  static const String testNickname = '테스트유저';
  static const String testToken = 'test-jwt-token';
}
