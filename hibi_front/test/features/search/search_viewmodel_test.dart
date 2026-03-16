/// Search ViewModel 테스트

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/search/models/search_models.dart';
import 'package:hidi/features/search/repos/search_repo.dart';
import 'package:hidi/features/search/viewmodels/search_viewmodel.dart';

void main() {
  group('SearchViewModel', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          searchRepoProvider.overrideWithValue(SearchRepository(useMock: true)),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should have empty query', () {
      final state = container.read(searchViewModelProvider);

      expect(state.query, '');
      expect(state.result, isNull);
      expect(state.isLoading, false);
      expect(state.selectedCategory, SearchCategory.all);
    });

    test('onQueryChanged should update query', () {
      final notifier = container.read(searchViewModelProvider.notifier);

      notifier.onQueryChanged('test');

      final state = container.read(searchViewModelProvider);
      expect(state.query, 'test');
    });

    test('onQueryChanged with short query should not trigger search', () {
      final notifier = container.read(searchViewModelProvider.notifier);

      notifier.onQueryChanged('a');

      final state = container.read(searchViewModelProvider);
      expect(state.query, 'a');
      expect(state.result, isNull);
      expect(state.isLoading, false);
    });

    test('search should update result', () async {
      final notifier = container.read(searchViewModelProvider.notifier);

      await notifier.search('test query');

      final state = container.read(searchViewModelProvider);
      expect(state.query, 'test query');
      expect(state.isLoading, false);
    });

    test('search with short query should not search', () async {
      final notifier = container.read(searchViewModelProvider.notifier);

      await notifier.search('a');

      final state = container.read(searchViewModelProvider);
      expect(state.result, isNull);
    });

    test('selectCategory should update selected category', () {
      final notifier = container.read(searchViewModelProvider.notifier);

      notifier.selectCategory(SearchCategory.songs);

      final state = container.read(searchViewModelProvider);
      expect(state.selectedCategory, SearchCategory.songs);
    });

    test('clearQuery should reset query and result', () {
      final notifier = container.read(searchViewModelProvider.notifier);
      notifier.onQueryChanged('test');

      notifier.clearQuery();

      final state = container.read(searchViewModelProvider);
      expect(state.query, '');
      expect(state.result, isNull);
      expect(state.isLoading, false);
    });
  });

  group('SearchState', () {
    test('hasResult should be true when result exists and query is not empty', () {
      final state = SearchState(
        query: 'test',
        result: SearchResult(
          songs: [],
          artists: [],
          posts: [],
          users: [],
          totalSongs: 0,
          totalArtists: 0,
          totalPosts: 0,
          totalUsers: 0,
        ),
      );

      expect(state.hasResult, true);
    });

    test('hasResult should be false when query is empty', () {
      final state = SearchState(
        query: '',
        result: SearchResult(
          songs: [],
          artists: [],
          posts: [],
          users: [],
          totalSongs: 0,
          totalArtists: 0,
          totalPosts: 0,
          totalUsers: 0,
        ),
      );

      expect(state.hasResult, false);
    });

    test('hasResult should be false when result is null', () {
      final state = SearchState(
        query: 'test',
        result: null,
      );

      expect(state.hasResult, false);
    });

    test('isEmpty should be true when result has no items', () {
      final state = SearchState(
        query: 'test',
        result: SearchResult(
          songs: [],
          artists: [],
          posts: [],
          users: [],
          totalSongs: 0,
          totalArtists: 0,
          totalPosts: 0,
          totalUsers: 0,
        ),
      );

      expect(state.isEmpty, true);
    });

    test('copyWith should update only specified fields', () {
      final state = SearchState();

      final updated = state.copyWith(
        query: 'test',
        isLoading: true,
      );

      expect(updated.query, 'test');
      expect(updated.isLoading, true);
      expect(updated.selectedCategory, SearchCategory.all);
    });

    test('copyWith with error should update error field', () {
      final state = SearchState();

      final updated = state.copyWith(error: 'Error message');

      expect(updated.error, 'Error message');
    });

    test('copyWith without error should clear error field', () {
      final state = SearchState(error: 'Error');

      final updated = state.copyWith(query: 'new');

      expect(updated.error, isNull);
    });
  });
}
