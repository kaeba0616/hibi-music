import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/comments/models/comment_models.dart';
import 'package:hidi/features/comments/widgets/comment_card.dart';

void main() {
  group('CommentCard', () {
    late Comment testComment;
    late Comment testReply;
    late Comment deletedComment;

    setUp(() {
      testComment = Comment(
        id: 1,
        postId: 1,
        author: CommentAuthor(
          id: 1,
          nickname: '테스트유저',
          username: 'test_user',
          profileImage: null,
        ),
        content: '테스트 댓글입니다.',
        likeCount: 5,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      testReply = Comment(
        id: 2,
        postId: 1,
        author: CommentAuthor(
          id: 2,
          nickname: '답글유저',
          username: 'reply_user',
          profileImage: null,
        ),
        content: '@테스트유저 답글입니다.',
        parentId: 1,
        parentAuthorNickname: '테스트유저',
        likeCount: 2,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      deletedComment = Comment.deleted(
        id: 3,
        postId: 1,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
    });

    Widget buildTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: child,
          ),
        ),
      );
    }

    testWidgets('displays comment author nickname', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        CommentCard(comment: testComment),
      ));

      expect(find.text('테스트유저'), findsOneWidget);
    });

    testWidgets('displays comment content', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        CommentCard(comment: testComment),
      ));

      expect(find.text('테스트 댓글입니다.'), findsOneWidget);
    });

    testWidgets('displays like count when greater than 0', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        CommentCard(comment: testComment),
      ));

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows reply button for non-reply comments', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        CommentCard(
          comment: testComment,
          isReply: false,
          onReplyTap: () {},
        ),
      ));

      expect(find.text('답글'), findsOneWidget);
    });

    testWidgets('hides reply button for reply comments', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        CommentCard(
          comment: testReply,
          isReply: true,
        ),
      ));

      expect(find.text('답글'), findsNothing);
    });

    testWidgets('shows more menu for own comments', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        CommentCard(
          comment: testComment,
          isOwnComment: true,
          onDeleteTap: () {},
        ),
      ));

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('hides more menu for other users comments', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        CommentCard(
          comment: testComment,
          isOwnComment: false,
        ),
      ));

      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets('shows deleted comment message', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        CommentCard(comment: deletedComment),
      ));

      expect(find.text('삭제된 댓글입니다'), findsOneWidget);
    });

    testWidgets('shows filled heart icon when liked', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        CommentCard(
          comment: testReply,
          isReply: true,
        ),
      ));

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('shows outline heart icon when not liked', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        CommentCard(comment: testComment),
      ));

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('calls onLikeTap when like button is tapped', (tester) async {
      bool likeTapped = false;

      await tester.pumpWidget(buildTestWidget(
        CommentCard(
          comment: testComment,
          onLikeTap: () => likeTapped = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(likeTapped, isTrue);
    });

    testWidgets('calls onReplyTap when reply button is tapped', (tester) async {
      bool replyTapped = false;

      await tester.pumpWidget(buildTestWidget(
        CommentCard(
          comment: testComment,
          isReply: false,
          onReplyTap: () => replyTapped = true,
        ),
      ));

      await tester.tap(find.text('답글'));
      expect(replyTapped, isTrue);
    });
  });

  group('CommentCardSkeleton', () {
    testWidgets('renders skeleton for main comment', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommentCardSkeleton(isReply: false),
          ),
        ),
      );

      // 스켈레톤이 렌더링되는지 확인
      expect(find.byType(CommentCardSkeleton), findsOneWidget);
    });

    testWidgets('renders skeleton for reply comment', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CommentCardSkeleton(isReply: true),
          ),
        ),
      );

      expect(find.byType(CommentCardSkeleton), findsOneWidget);
    });
  });
}
