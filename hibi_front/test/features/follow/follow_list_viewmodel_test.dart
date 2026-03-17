/// Follow List ViewModel 테스트

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/follow/models/follow_models.dart';
import 'package:hidi/features/follow/repos/follow_repo.dart';
import 'package:hidi/features/follow/viewmodels/follow_list_viewmodel.dart';

void main() {
  group('FollowListViewModel', () {
    late ProviderContainer container;
    late FollowListArg testArg;

    setUp(() {
      testArg = FollowListArg(userId: 1);
      container = ProviderContainer(
        overrides: [
          followRepoProvider.overrideWithValue(FollowRepository(useMock: true)),
        ],
      );
    });

    tearDown(() async {
      // Wait for any microtask-triggered operations to complete before disposing
      // Mock getFollowers (500ms) + getFollowing (400ms) = ~1000ms
      await Future.delayed(const Duration(milliseconds: 1500));
      container.dispose();
    });

    test('initial state should be loading with followers tab', () async {
      final state = container.read(followListViewModelProvider(testArg));

      expect(state.isLoading, true);
      expect(state.currentTab, FollowListTab.followers);
      expect(state.followers, isEmpty);
      expect(state.following, isEmpty);
    });

    test('initial state with following tab should start on following tab', () async {
      final followingArg = FollowListArg(
        userId: 1,
        initialTab: FollowListTab.following,
      );
      final state = container.read(followListViewModelProvider(followingArg));

      expect(state.currentTab, FollowListTab.following);
    });

    test('loadList should update state with followers and following', () async {
      final notifier = container.read(followListViewModelProvider(testArg).notifier);
      // Wait for microtask-triggered loadList to complete first
      await Future.delayed(const Duration(milliseconds: 1200));

      await notifier.loadList();

      final state = container.read(followListViewModelProvider(testArg));
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('changeTab should update current tab', () async {
      final notifier = container.read(followListViewModelProvider(testArg).notifier);
      await notifier.loadList();

      notifier.changeTab(FollowListTab.following);

      final state = container.read(followListViewModelProvider(testArg));
      expect(state.currentTab, FollowListTab.following);
    });

    test('refresh should reload list', () async {
      final notifier = container.read(followListViewModelProvider(testArg).notifier);
      await notifier.loadList();

      await notifier.refresh();

      final state = container.read(followListViewModelProvider(testArg));
      expect(state.isLoading, false);
    });

    test('clearError should set error to null', () async {
      final notifier = container.read(followListViewModelProvider(testArg).notifier);

      notifier.clearError();

      final state = container.read(followListViewModelProvider(testArg));
      expect(state.error, isNull);
    });
  });

  group('FollowListState', () {
    test('currentList should return followers when tab is followers', () {
      final follower = FollowUser(
        id: 1,
        nickname: 'Follower',
        username: 'follower',
      );
      final state = FollowListState(
        followers: [follower],
        following: [],
        currentTab: FollowListTab.followers,
      );

      expect(state.currentList.length, 1);
      expect(state.currentList.first, follower);
    });

    test('currentList should return following when tab is following', () {
      final following = FollowUser(
        id: 2,
        nickname: 'Following',
        username: 'following',
      );
      final state = FollowListState(
        followers: [],
        following: [following],
        currentTab: FollowListTab.following,
      );

      expect(state.currentList.length, 1);
      expect(state.currentList.first, following);
    });

    test('isEmpty should be true when current list is empty', () {
      final state = FollowListState(
        followers: [],
        following: [],
        currentTab: FollowListTab.followers,
      );

      expect(state.isEmpty, true);
    });

    test('isEmpty should be false when current list has items', () {
      final follower = FollowUser(
        id: 1,
        nickname: 'Follower',
        username: 'follower',
      );
      final state = FollowListState(
        followers: [follower],
        following: [],
        currentTab: FollowListTab.followers,
      );

      expect(state.isEmpty, false);
    });

    test('copyWith should update only specified fields', () {
      final state = FollowListState();

      final updated = state.copyWith(
        followerCount: 10,
        followingCount: 5,
        isLoading: true,
      );

      expect(updated.followerCount, 10);
      expect(updated.followingCount, 5);
      expect(updated.isLoading, true);
      expect(updated.currentTab, FollowListTab.followers);
    });

    test('copyWith with clearError should set error to null', () {
      final state = FollowListState(error: 'Error');

      final updated = state.copyWith(clearError: true);

      expect(updated.error, isNull);
    });
  });

  group('FollowListArg', () {
    test('equality should work correctly', () {
      final arg1 = FollowListArg(userId: 1, initialTab: FollowListTab.followers);
      final arg2 = FollowListArg(userId: 1, initialTab: FollowListTab.followers);
      final arg3 = FollowListArg(userId: 2, initialTab: FollowListTab.followers);

      expect(arg1, equals(arg2));
      expect(arg1, isNot(equals(arg3)));
    });

    test('hashCode should be consistent with equality', () {
      final arg1 = FollowListArg(userId: 1, initialTab: FollowListTab.followers);
      final arg2 = FollowListArg(userId: 1, initialTab: FollowListTab.followers);

      expect(arg1.hashCode, equals(arg2.hashCode));
    });
  });
}
