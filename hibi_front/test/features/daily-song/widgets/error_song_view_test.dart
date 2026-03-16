import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/daily-song/views/widgets/error_song_view.dart';

void main() {
  group('ErrorSongView Widget', () {
    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorSongView(
              message: '연결을 확인해주세요',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('연결을 확인해주세요'), findsOneWidget);
    });

    testWidgets('should display error icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorSongView(
              message: '에러 발생',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show retry button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorSongView(
              message: '에러 발생',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('다시 시도'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should call onRetry when retry button tapped', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorSongView(
              message: '에러 발생',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('다시 시도'));
      await tester.pump();

      expect(retried, isTrue);
    });
  });
}
