import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/users/views/my_comments_view.dart';
import 'package:hidi/features/settings/widgets/push_notification_tile.dart';

void main() {
  group('MyCommentsView', () {
    Widget buildWidget() {
      return const ProviderScope(
        child: MaterialApp(home: MyCommentsView()),
      );
    }

    testWidgets('AppBar에 "내가 쓴 댓글" 타이틀 표시', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('내가 쓴 댓글'), findsOneWidget);
    });

    testWidgets('초기 로딩 인디케이터 표시', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('PushNotificationTile', () {
    Widget buildWidget() {
      return const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: PushNotificationTile()),
        ),
      );
    }

    testWidgets('푸시 알림 텍스트가 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byType(SwitchListTile), findsOneWidget);
    });
  });
}
