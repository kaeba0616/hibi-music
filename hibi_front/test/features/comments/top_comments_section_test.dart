import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/comments/models/comment_models.dart';
import 'package:hidi/features/comments/widgets/top_comments_section.dart';

void main() {
  group('TopCommentsSection', () {
    late List<Comment> topComments;

    setUp(() {
      topComments = [
        Comment(
          id: 1,
          postId: 1,
          author: CommentAuthor(
            id: 1,
            nickname: '유저1',
            username: 'user1',
            profileImage: null,
          ),
          content: '최고의 곡이에요!',
          likeCount: 50,
          isLiked: false,
          createdAt: DateTime.now(),
        ),
        Comment(
          id: 2,
          postId: 1,
          author: CommentAuthor(
            id: 2,
            nickname: '유저2',
            username: 'user2',
            profileImage: null,
          ),
          content: '매일 듣고 있어요',
          likeCount: 30,
          isLiked: true,
          createdAt: DateTime.now(),
        ),
        Comment(
          id: 3,
          postId: 1,
          author: CommentAuthor(
            id: 3,
            nickname: '유저3',
            username: 'user3',
            profileImage: null,
          ),
          content: 'YOASOBI 최고!',
          likeCount: 20,
          isLiked: false,
          createdAt: DateTime.now(),
        ),
      ];
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: TopCommentsSection(
            comments: topComments,
            onLikeTap: (_) {},
          ),
        ),
      );
    }

    testWidgets('Top3 댓글 내용이 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('최고의 곡이에요!'), findsOneWidget);
      expect(find.text('매일 듣고 있어요'), findsOneWidget);
      expect(find.text('YOASOBI 최고!'), findsOneWidget);
    });

    testWidgets('Top3 댓글 작성자가 표시됨', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('유저1'), findsOneWidget);
      expect(find.text('유저2'), findsOneWidget);
      expect(find.text('유저3'), findsOneWidget);
    });

    testWidgets('빈 리스트일 때 아무것도 표시하지 않음', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TopCommentsSection(
              comments: const [],
              onLikeTap: (_) {},
            ),
          ),
        ),
      );
      expect(find.byType(TopCommentsSection), findsOneWidget);
    });
  });
}
