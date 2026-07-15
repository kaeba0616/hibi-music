import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/comments/mocks/comment_mock.dart' as comment_mock;
import 'package:hidi/features/comments/viewmodels/comment_viewmodel.dart';
import 'package:hidi/features/posts/mocks/post_mock.dart' as post_mock;
import 'package:hidi/features/posts/viewmodels/post_viewmodel.dart';
import 'package:hidi/features/users/models/user.dart';

class _FakeAuthRepo extends AuthenticationRepository {
  @override
  User? get user =>
      User(id: 42, email: 'me@hibi.app', nickname: '나', roleType: 'USER');
}

void main() {
  group('currentUserId (본인 콘텐츠 판별)', () {
    test('로그인 사용자가 있으면 실제 회원 ID를 반환한다', () {
      final container = ProviderContainer(
        overrides: [authRepo.overrideWithValue(_FakeAuthRepo())],
      );
      addTearDown(container.dispose);

      final postVm =
          container.read(postDetailViewModelProvider(1).notifier);
      final commentVm =
          container.read(commentSectionViewModelProvider(1).notifier);

      expect(postVm.currentUserId, 42);
      expect(commentVm.currentUserId, 42);
    });

    test('미로그인 상태의 mock 모드에서는 기존 mock ID를 유지한다', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final postVm =
          container.read(postDetailViewModelProvider(1).notifier);
      final commentVm =
          container.read(commentSectionViewModelProvider(1).notifier);

      expect(postVm.currentUserId, post_mock.mockCurrentUserId);
      expect(commentVm.currentUserId, comment_mock.mockCurrentUserId);
    });
  });
}
