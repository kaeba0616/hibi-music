/// Post ViewModel 테스트

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/posts/models/post_models.dart';
import 'package:hidi/features/posts/repos/post_repo.dart';
import 'package:hidi/features/posts/viewmodels/post_viewmodel.dart';

void main() {
  group('PostDetailViewModel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          postRepoProvider.overrideWithValue(PostRepository(useMock: true)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be loading', () {
      final state = container.read(postDetailViewModelProvider(1));

      expect(state.isLoading, true);
      expect(state.post, isNull);
      expect(state.error, isNull);
    });

    test('loadPost should update state with post data', () async {
      final notifier = container.read(postDetailViewModelProvider(1).notifier);

      await notifier.loadPost(1);

      final state = container.read(postDetailViewModelProvider(1));
      expect(state.post, isNotNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('loadPost with invalid id should set error', () async {
      final notifier = container.read(postDetailViewModelProvider(9999).notifier);

      await notifier.loadPost(9999);

      final state = container.read(postDetailViewModelProvider(9999));
      expect(state.post, isNull);
      expect(state.isLoading, false);
    });

    test('toggleLike should update like status', () async {
      final notifier = container.read(postDetailViewModelProvider(1).notifier);
      await notifier.loadPost(1);

      final initialState = container.read(postDetailViewModelProvider(1));
      final initialLikeCount = initialState.post!.likeCount;
      final initialIsLiked = initialState.post!.isLiked;

      await notifier.toggleLike();

      final state = container.read(postDetailViewModelProvider(1));
      expect(state.post!.isLiked, !initialIsLiked);
      if (initialIsLiked) {
        expect(state.post!.likeCount, initialLikeCount - 1);
      } else {
        expect(state.post!.likeCount, initialLikeCount + 1);
      }
    });

    test('deletePost should return true on success', () async {
      final notifier = container.read(postDetailViewModelProvider(1).notifier);
      await notifier.loadPost(1);

      final result = await notifier.deletePost();

      expect(result, true);
    });
  });

  group('PostDetailState', () {
    test('copyWith should update only specified fields', () {
      final state = PostDetailState();
      final post = Post(
        id: 1,
        authorId: 1,
        authorName: 'Test',
        authorProfileUrl: '',
        content: 'Test content',
        images: [],
        likeCount: 0,
        commentCount: 0,
        isLiked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = state.copyWith(post: post, isLoading: true);

      expect(updated.post, post);
      expect(updated.isLoading, true);
      expect(updated.error, isNull);
    });

    test('copyWith with clearError should set error to null', () {
      final state = PostDetailState(error: 'Error');

      final updated = state.copyWith(clearError: true);

      expect(updated.error, isNull);
    });
  });

  group('PostCreateViewModel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          postRepoProvider.overrideWithValue(PostRepository(useMock: true)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should have empty values', () {
      final state = container.read(postCreateViewModelProvider);

      expect(state.content, '');
      expect(state.images, isEmpty);
      expect(state.taggedSong, isNull);
      expect(state.isSubmitting, false);
      expect(state.canSubmit, false);
    });

    test('setContent should update content', () {
      final notifier = container.read(postCreateViewModelProvider.notifier);

      notifier.setContent('Test content');

      final state = container.read(postCreateViewModelProvider);
      expect(state.content, 'Test content');
      expect(state.canSubmit, true);
    });

    test('addImage should add image up to 4', () {
      final notifier = container.read(postCreateViewModelProvider.notifier);

      notifier.addImage('image1.jpg');
      notifier.addImage('image2.jpg');
      notifier.addImage('image3.jpg');
      notifier.addImage('image4.jpg');
      notifier.addImage('image5.jpg'); // Should not be added

      final state = container.read(postCreateViewModelProvider);
      expect(state.images.length, 4);
    });

    test('removeImage should remove image at index', () {
      final notifier = container.read(postCreateViewModelProvider.notifier);
      notifier.addImage('image1.jpg');
      notifier.addImage('image2.jpg');

      notifier.removeImage(0);

      final state = container.read(postCreateViewModelProvider);
      expect(state.images.length, 1);
      expect(state.images.first, 'image2.jpg');
    });

    test('setTaggedSong should update tagged song', () {
      final notifier = container.read(postCreateViewModelProvider.notifier);
      final song = TaggedSong(
        id: 1,
        title: 'Test Song',
        artist: 'Test Artist',
        albumArt: '',
      );

      notifier.setTaggedSong(song);

      final state = container.read(postCreateViewModelProvider);
      expect(state.taggedSong, song);
    });

    test('setTaggedSong with null should clear tagged song', () {
      final notifier = container.read(postCreateViewModelProvider.notifier);
      final song = TaggedSong(
        id: 1,
        title: 'Test Song',
        artist: 'Test Artist',
        albumArt: '',
      );
      notifier.setTaggedSong(song);

      notifier.setTaggedSong(null);

      final state = container.read(postCreateViewModelProvider);
      expect(state.taggedSong, isNull);
    });

    test('submit should return post on success', () async {
      final notifier = container.read(postCreateViewModelProvider.notifier);
      notifier.setContent('Test content');

      final post = await notifier.submit();

      expect(post, isNotNull);
      expect(post!.content, 'Test content');
    });

    test('submit without content should return null', () async {
      final notifier = container.read(postCreateViewModelProvider.notifier);

      final post = await notifier.submit();

      expect(post, isNull);
    });

    test('reset should clear all state', () {
      final notifier = container.read(postCreateViewModelProvider.notifier);
      notifier.setContent('Test');
      notifier.addImage('image.jpg');

      notifier.reset();

      final state = container.read(postCreateViewModelProvider);
      expect(state.content, '');
      expect(state.images, isEmpty);
    });
  });

  group('PostEditorState', () {
    test('canSubmit should be true when content is not empty and not submitting', () {
      final state = PostEditorState(content: 'Test');

      expect(state.canSubmit, true);
    });

    test('canSubmit should be false when content is empty', () {
      final state = PostEditorState(content: '');

      expect(state.canSubmit, false);
    });

    test('canSubmit should be false when isSubmitting is true', () {
      final state = PostEditorState(content: 'Test', isSubmitting: true);

      expect(state.canSubmit, false);
    });

    test('copyWith with clearTaggedSong should set taggedSong to null', () {
      final song = TaggedSong(
        id: 1,
        title: 'Test',
        artist: 'Artist',
        albumArt: '',
      );
      final state = PostEditorState(taggedSong: song);

      final updated = state.copyWith(clearTaggedSong: true);

      expect(updated.taggedSong, isNull);
    });
  });

  group('SongSearchViewModel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          postRepoProvider.overrideWithValue(PostRepository(useMock: true)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should have empty values', () {
      final state = container.read(songSearchViewModelProvider);

      expect(state.query, '');
      expect(state.results, isEmpty);
      expect(state.isSearching, false);
    });

    test('search should update state with results', () async {
      final notifier = container.read(songSearchViewModelProvider.notifier);

      await notifier.search('test');

      final state = container.read(songSearchViewModelProvider);
      expect(state.query, 'test');
      expect(state.isSearching, false);
    });

    test('reset should clear all state', () {
      final notifier = container.read(songSearchViewModelProvider.notifier);

      notifier.reset();

      final state = container.read(songSearchViewModelProvider);
      expect(state.query, '');
      expect(state.results, isEmpty);
    });
  });
}
