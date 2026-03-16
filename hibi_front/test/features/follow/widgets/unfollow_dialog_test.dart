import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/follow/widgets/unfollow_dialog.dart';

void main() {
  group('UnfollowDialog', () {
    testWidgets('should display username in dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => UnfollowDialog.show(context, 'test_user'),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.textContaining('@test_user'), findsOneWidget);
      expect(find.textContaining('언팔로우'), findsWidgets);
    });

    testWidgets('should display explanation text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => UnfollowDialog.show(context, 'test_user'),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.textContaining('피드에서 사라집니다'), findsOneWidget);
    });

    testWidgets('should return false when cancel is pressed', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await UnfollowDialog.show(context, 'test_user');
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('should return true when unfollow is pressed', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await UnfollowDialog.show(context, 'test_user');
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Find the TextButton with '언팔로우' text
      await tester.tap(find.widgetWithText(TextButton, '언팔로우'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('unfollow button should be red', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => UnfollowDialog.show(context, 'test_user'),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      final unfollowButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, '언팔로우'),
      );
      final textWidget = tester.widget<Text>(
        find.descendant(
          of: find.byWidget(unfollowButton),
          matching: find.text('언팔로우'),
        ),
      );

      expect(textWidget.style?.color, equals(Colors.red));
    });
  });
}
