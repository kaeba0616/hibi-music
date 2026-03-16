import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/follow/widgets/follow_button.dart';

void main() {
  group('FollowButton', () {
    testWidgets('should display "팔로우" when not following', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowButton(
              isFollowing: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('팔로우'), findsOneWidget);
      expect(find.text('팔로잉'), findsNothing);
    });

    testWidgets('should display "팔로잉" when following', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowButton(
              isFollowing: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('팔로잉'), findsOneWidget);
      expect(find.text('팔로우'), findsNothing);
    });

    testWidgets('should show loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowButton(
              isFollowing: false,
              isLoading: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should call onTap when pressed', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowButton(
              isFollowing: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should not call onTap when loading', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowButton(
              isFollowing: false,
              isLoading: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('compact button should be smaller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowButton(
              isFollowing: false,
              isCompact: true,
              onTap: () {},
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(80));
      expect(sizedBox.height, equals(32));
    });
  });

  group('EditProfileButton', () {
    testWidgets('should display "프로필 수정"', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditProfileButton(onTap: () {}),
          ),
        ),
      );

      expect(find.text('프로필 수정'), findsOneWidget);
    });

    testWidgets('should call onTap when pressed', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditProfileButton(onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
