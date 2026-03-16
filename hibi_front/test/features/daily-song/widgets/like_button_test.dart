import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/daily-song/views/widgets/like_button.dart';

void main() {
  group('LikeButton Widget', () {
    testWidgets('should display unfilled heart when not liked', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LikeButton(
              isLiked: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // unfilled heart icon should be present
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('should display filled heart when liked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LikeButton(
              isLiked: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // filled heart icon should be present
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LikeButton(
              isLiked: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(LikeButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should display like count when showCount is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LikeButton(
              isLiked: false,
              onTap: () {},
              likeCount: 1542,
              showCount: true,
            ),
          ),
        ),
      );

      // Should display formatted count (1.5K)
      expect(find.text('1.5K'), findsOneWidget);
    });

    testWidgets('should format large numbers correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LikeButton(
              isLiked: false,
              onTap: () {},
              likeCount: 1000000,
              showCount: true,
            ),
          ),
        ),
      );

      expect(find.text('1.0M'), findsOneWidget);
    });

    testWidgets('should show small numbers without formatting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LikeButton(
              isLiked: false,
              onTap: () {},
              likeCount: 500,
              showCount: true,
            ),
          ),
        ),
      );

      expect(find.text('500'), findsOneWidget);
    });
  });
}
