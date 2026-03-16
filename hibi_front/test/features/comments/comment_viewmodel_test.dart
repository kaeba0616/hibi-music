/// Comment ViewModel 테스트

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/comments/models/comment_models.dart';
import 'package:hidi/features/comments/repos/comment_repo.dart';
import 'package:hidi/features/comments/viewmodels/comment_viewmodel.dart';

void main() {
  group('CommentSectionViewModel', () {
    late ProviderContainer container;
    const testPostId = 1;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          commentRepoProvider.overrideWithValue(CommentRepository(useMock: true)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be loading', () {
      final state = container.read(commentSectionViewModelProvider(testPostId));

      expect(state.isLoading, true);
      expect(state.comments, isEmpty);
      expect(state.error, isNull);
    });

    test('loadComments should update state with comments', () async {
      final notifier = container.read(commentSectionViewModelProvider(testPostId).notifier);

      await notifier.loadComments();

      final state = container.read(commentSectionViewModelProvider(testPostId));
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('submitComment should add comment to list', () async {
      final notifier = container.read(commentSectionViewModelProvider(testPostId).notifier);
      await notifier.loadComments();
      final initialCount = container.read(commentSectionViewModelProvider(testPostId)).totalCount;

      final success = await notifier.submitComment('Test comment');

      expect(success, true);
      final state = container.read(commentSectionViewModelProvider(testPostId));
      expect(state.totalCount, initialCount + 1);
      expect(state.isSubmitting, false);
    });

    test('submitComment with empty content should return false', () async {
      final notifier = container.read(commentSectionViewModelProvider(testPostId).notifier);

      final success = await notifier.submitComment('');

      expect(success, false);
    });

    test('submitComment with whitespace only should return false', () async {
      final notifier = container.read(commentSectionViewModelProvider(testPostId).notifier);

      final success = await notifier.submitComment('   ');

      expect(success, false);
    });

    test('startReply should set replyTo', () async {
      final notifier = container.read(commentSectionViewModelProvider(testPostId).notifier);
      await notifier.loadComments();

      final comment = Comment(
        id: 1,
        postId: testPostId,
        authorId: 1,
        authorName: 'Test',
        authorProfileUrl: '',
        content: 'Test',
        likeCount: 0,
        isLiked: false,
        createdAt: DateTime.now(),
        replies: [],
      );

      notifier.startReply(comment);

      final state = container.read(commentSectionViewModelProvider(testPostId));
      expect(state.replyTo, comment);
      expect(state.isReplyMode, true);
    });

    test('cancelReply should clear replyTo', () async {
      final notifier = container.read(commentSectionViewModelProvider(testPostId).notifier);
      await notifier.loadComments();

      final comment = Comment(
        id: 1,
        postId: testPostId,
        authorId: 1,
        authorName: 'Test',
        authorProfileUrl: '',
        content: 'Test',
        likeCount: 0,
        isLiked: false,
        createdAt: DateTime.now(),
        replies: [],
      );

      notifier.startReply(comment);
      notifier.cancelReply();

      final state = container.read(commentSectionViewModelProvider(testPostId));
      expect(state.replyTo, isNull);
      expect(state.isReplyMode, false);
    });

    test('clearError should set error to null', () async {
      final notifier = container.read(commentSectionViewModelProvider(testPostId).notifier);

      notifier.clearError();

      final state = container.read(commentSectionViewModelProvider(testPostId));
      expect(state.error, isNull);
    });

    test('deleteComment should remove comment from list', () async {
      final notifier = container.read(commentSectionViewModelProvider(testPostId).notifier);
      await notifier.loadComments();

      final state = container.read(commentSectionViewModelProvider(testPostId));
      if (state.comments.isNotEmpty) {
        final commentId = state.comments.first.id;
        final initialCount = state.totalCount;

        final success = await notifier.deleteComment(commentId);

        expect(success, true);
        final newState = container.read(commentSectionViewModelProvider(testPostId));
        expect(newState.totalCount, lessThanOrEqualTo(initialCount));
      }
    });
  });

  group('CommentSectionState', () {
    test('isEmpty should be true when comments list is empty', () {
      final state = CommentSectionState(comments: []);

      expect(state.isEmpty, true);
    });

    test('isEmpty should be false when comments list has items', () {
      final comment = Comment(
        id: 1,
        postId: 1,
        authorId: 1,
        authorName: 'Test',
        authorProfileUrl: '',
        content: 'Test',
        likeCount: 0,
        isLiked: false,
        createdAt: DateTime.now(),
        replies: [],
      );
      final state = CommentSectionState(comments: [comment]);

      expect(state.isEmpty, false);
    });

    test('isReplyMode should be true when replyTo is set', () {
      final comment = Comment(
        id: 1,
        postId: 1,
        authorId: 1,
        authorName: 'Test',
        authorProfileUrl: '',
        content: 'Test',
        likeCount: 0,
        isLiked: false,
        createdAt: DateTime.now(),
        replies: [],
      );
      final state = CommentSectionState(replyTo: comment);

      expect(state.isReplyMode, true);
    });

    test('isReplyMode should be false when replyTo is null', () {
      final state = CommentSectionState();

      expect(state.isReplyMode, false);
    });

    test('copyWith should update only specified fields', () {
      final state = CommentSectionState();

      final updated = state.copyWith(isLoading: true, totalCount: 10);

      expect(updated.isLoading, true);
      expect(updated.totalCount, 10);
      expect(updated.comments, isEmpty);
    });

    test('copyWith with clearError should set error to null', () {
      final state = CommentSectionState(error: 'Error');

      final updated = state.copyWith(clearError: true);

      expect(updated.error, isNull);
    });

    test('copyWith with clearReplyTo should set replyTo to null', () {
      final comment = Comment(
        id: 1,
        postId: 1,
        authorId: 1,
        authorName: 'Test',
        authorProfileUrl: '',
        content: 'Test',
        likeCount: 0,
        isLiked: false,
        createdAt: DateTime.now(),
        replies: [],
      );
      final state = CommentSectionState(replyTo: comment);

      final updated = state.copyWith(clearReplyTo: true);

      expect(updated.replyTo, isNull);
    });
  });
}
