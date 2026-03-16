import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/posts/models/post_models.dart';
import 'package:hidi/features/posts/widgets/post_card.dart';

void main() {
  final testAuthor = PostAuthor(
    id: 1,
    nickname: '테스트유저',
    username: 'testuser',
    profileImage: null,
  );

  final testSong = TaggedSong(
    id: 1,
    titleKor: '밤을 달리다',
    titleJp: '夜に駆ける',
    artistName: 'YOASOBI',
    albumImageUrl: null,
    albumName: 'THE BOOK',
    releaseYear: 2021,
  );

  final testPost = Post(
    id: 1,
    author: testAuthor,
    content: '오늘 들은 곡 너무 좋아요! YOASOBI 신곡 최고',
    images: [],
    taggedSong: testSong,
    likeCount: 24,
    commentCount: 5,
    isLiked: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
  );

  group('PostCard', () {
    testWidgets('renders author information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(post: testPost),
          ),
        ),
      );

      expect(find.text('테스트유저'), findsOneWidget);
      expect(find.textContaining('@testuser'), findsOneWidget);
    });

    testWidgets('renders post content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(post: testPost),
          ),
        ),
      );

      expect(find.text('오늘 들은 곡 너무 좋아요! YOASOBI 신곡 최고'), findsOneWidget);
    });

    testWidgets('renders like count and comment count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(post: testPost),
          ),
        ),
      );

      expect(find.text('24'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders song tag when present', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(post: testPost),
          ),
        ),
      );

      expect(find.text('밤을 달리다'), findsOneWidget);
      expect(find.text('YOASOBI'), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              post: testPost,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PostCard));
      expect(tapped, isTrue);
    });

    testWidgets('calls onLikeTap when like button is tapped', (tester) async {
      bool likeTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              post: testPost,
              onLikeTap: () => likeTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(likeTapped, isTrue);
    });

    testWidgets('shows filled heart when isLiked is true', (tester) async {
      final likedPost = testPost.copyWith(isLiked: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(post: likedPost),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('does not render song tag when absent', (tester) async {
      final postWithoutSong = testPost.copyWith(clearTaggedSong: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(post: postWithoutSong),
          ),
        ),
      );

      expect(find.text('밤을 달리다'), findsNothing);
    });
  });

  group('PostCardSkeleton', () {
    testWidgets('renders skeleton placeholders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PostCardSkeleton(),
          ),
        ),
      );

      // 스켈레톤이 렌더링되는지 확인
      expect(find.byType(PostCardSkeleton), findsOneWidget);
    });
  });
}
