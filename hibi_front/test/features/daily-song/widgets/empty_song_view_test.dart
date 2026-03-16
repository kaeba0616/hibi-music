import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/daily-song/views/widgets/empty_song_view.dart';

void main() {
  group('EmptySongView Widget', () {
    testWidgets('should display empty message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySongView(),
          ),
        ),
      );

      expect(find.text('아직 오늘의 노래가\n준비되지 않았어요'), findsOneWidget);
      expect(find.text('잠시 후 다시 확인해주세요'), findsOneWidget);
    });

    testWidgets('should display music note icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySongView(),
          ),
        ),
      );

      expect(find.byIcon(Icons.music_note_outlined), findsOneWidget);
    });

    testWidgets('should show refresh button when onRefresh is provided', (tester) async {
      bool refreshed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptySongView(
              onRefresh: () => refreshed = true,
            ),
          ),
        ),
      );

      expect(find.text('새로고침'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      await tester.tap(find.text('새로고침'));
      await tester.pump();

      expect(refreshed, isTrue);
    });

    testWidgets('should not show refresh button when onRefresh is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptySongView(),
          ),
        ),
      );

      expect(find.text('새로고침'), findsNothing);
    });
  });
}
