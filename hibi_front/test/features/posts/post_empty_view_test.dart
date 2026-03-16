import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/posts/widgets/post_empty_view.dart';

void main() {
  group('PostEmptyView', () {
    testWidgets('renders empty state message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PostEmptyView(),
          ),
        ),
      );

      expect(find.text('아직 게시글이 없습니다'), findsOneWidget);
      expect(find.text('첫 번째 게시글을 작성해보세요!'), findsOneWidget);
    });

    testWidgets('shows create button when onCreateTap is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostEmptyView(
              onCreateTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('글쓰기'), findsOneWidget);
    });

    testWidgets('does not show create button when onCreateTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PostEmptyView(
              onCreateTap: null,
            ),
          ),
        ),
      );

      expect(find.text('글쓰기'), findsNothing);
    });

    testWidgets('calls onCreateTap when button is tapped', (tester) async {
      bool createTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostEmptyView(
              onCreateTap: () => createTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('글쓰기'));
      expect(createTapped, isTrue);
    });
  });

  group('PostErrorView', () {
    testWidgets('renders default error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PostErrorView(),
          ),
        ),
      );

      expect(find.text('게시글을 불러올 수 없습니다'), findsOneWidget);
    });

    testWidgets('renders custom error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PostErrorView(
              message: '네트워크 오류가 발생했습니다',
            ),
          ),
        ),
      );

      expect(find.text('네트워크 오류가 발생했습니다'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostErrorView(
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('does not show retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PostErrorView(
              onRetry: null,
            ),
          ),
        ),
      );

      expect(find.text('다시 시도'), findsNothing);
    });

    testWidgets('calls onRetry when button is tapped', (tester) async {
      bool retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostErrorView(
              onRetry: () => retryTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('다시 시도'));
      expect(retryTapped, isTrue);
    });
  });
}
