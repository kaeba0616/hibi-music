import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/follow/models/follow_models.dart';
import 'package:hidi/features/follow/widgets/follow_user_tile.dart';

void main() {
  final testUser = FollowUser(
    id: 1,
    nickname: '테스트유저',
    username: 'test_user',
    profileImage: null,
    isFollowing: false,
  );

  final followingUser = FollowUser(
    id: 2,
    nickname: '팔로잉유저',
    username: 'following_user',
    profileImage: 'https://example.com/profile.jpg',
    isFollowing: true,
  );

  group('FollowUserTile', () {
    testWidgets('should display user information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowUserTile(
              user: testUser,
              onTap: () {},
              onFollowTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('테스트유저'), findsOneWidget);
      expect(find.text('@test_user'), findsOneWidget);
    });

    testWidgets('should show follow button when not following', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowUserTile(
              user: testUser,
              onTap: () {},
              onFollowTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('팔로우'), findsOneWidget);
    });

    testWidgets('should show following button when following', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowUserTile(
              user: followingUser,
              onTap: () {},
              onFollowTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('팔로잉'), findsOneWidget);
    });

    testWidgets('should hide follow button for current user', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowUserTile(
              user: testUser,
              isCurrentUser: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('팔로우'), findsNothing);
      expect(find.text('팔로잉'), findsNothing);
    });

    testWidgets('should call onTap when tile is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowUserTile(
              user: testUser,
              onTap: () => tapped = true,
              onFollowTap: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('should call onFollowTap when follow button is tapped',
        (tester) async {
      bool followTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowUserTile(
              user: testUser,
              onTap: () {},
              onFollowTap: () => followTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('팔로우'));
      await tester.pump();

      expect(followTapped, isTrue);
    });

    testWidgets('should show person icon when no profile image', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FollowUserTile(
              user: testUser,
              onTap: () {},
              onFollowTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });

  group('FollowUserTileSkeleton', () {
    testWidgets('should render skeleton', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FollowUserTileSkeleton(),
          ),
        ),
      );

      expect(find.byType(FollowUserTileSkeleton), findsOneWidget);
    });
  });
}
