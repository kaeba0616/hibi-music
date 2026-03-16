import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/comments/models/comment_models.dart';
import 'package:hidi/features/comments/widgets/comment_input.dart';

void main() {
  group('CommentInput', () {
    late Comment testComment;

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
    });

    Widget buildTestWidget({
      Comment? replyTo,
      bool isLoading = false,
      void Function(String)? onSubmit,
      VoidCallback? onCancelReply,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const Spacer(),
              CommentInput(
                replyTo: replyTo,
                isLoading: isLoading,
                onSubmit: onSubmit,
                onCancelReply: onCancelReply,
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('displays placeholder text', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('댓글을 입력하세요...'), findsOneWidget);
    });

    testWidgets('displays reply placeholder when in reply mode', (tester) async {
      await tester.pumpWidget(buildTestWidget(replyTo: testComment));

      expect(find.text('답글을 입력하세요...'), findsOneWidget);
    });

    testWidgets('shows reply indicator when in reply mode', (tester) async {
      await tester.pumpWidget(buildTestWidget(replyTo: testComment));

      expect(find.text('@테스트유저님에게 답글'), findsOneWidget);
    });

    testWidgets('shows cancel button in reply mode', (tester) async {
      await tester.pumpWidget(buildTestWidget(replyTo: testComment));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onCancelReply when cancel button is tapped', (tester) async {
      bool cancelCalled = false;

      await tester.pumpWidget(buildTestWidget(
        replyTo: testComment,
        onCancelReply: () => cancelCalled = true,
      ));

      await tester.tap(find.byIcon(Icons.close));
      expect(cancelCalled, isTrue);
    });

    testWidgets('send button is disabled when input is empty', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 비활성화 상태에서 전송 버튼은 흐린 색상
      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);
    });

    testWidgets('send button is enabled when text is entered', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // 텍스트 입력
      await tester.enterText(find.byType(TextField), '테스트 댓글');
      await tester.pump();

      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('calls onSubmit with content when send button is tapped', (tester) async {
      String? submittedContent;

      await tester.pumpWidget(buildTestWidget(
        onSubmit: (content) => submittedContent = content,
      ));

      // 텍스트 입력
      await tester.enterText(find.byType(TextField), '테스트 댓글');
      await tester.pump();

      // 전송 버튼 탭
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(submittedContent, '테스트 댓글');
    });

    testWidgets('clears input after successful submit', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        onSubmit: (_) {},
      ));

      // 텍스트 입력
      await tester.enterText(find.byType(TextField), '테스트 댓글');
      await tester.pump();

      // 전송 버튼 탭
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      // 입력창이 비워졌는지 확인
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(buildTestWidget(isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('disables input when isLoading is true', (tester) async {
      await tester.pumpWidget(buildTestWidget(isLoading: true));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('does not submit empty content', (tester) async {
      bool submitCalled = false;

      await tester.pumpWidget(buildTestWidget(
        onSubmit: (_) => submitCalled = true,
      ));

      // 빈 상태에서 전송 버튼 탭
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(submitCalled, isFalse);
    });

    testWidgets('does not submit whitespace-only content', (tester) async {
      bool submitCalled = false;

      await tester.pumpWidget(buildTestWidget(
        onSubmit: (_) => submitCalled = true,
      ));

      // 공백만 입력
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();

      // 전송 버튼 탭
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(submitCalled, isFalse);
    });
  });
}
