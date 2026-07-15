import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/settings/widgets/push_notification_tile.dart';
import 'package:hidi/features/users/models/user.dart';
import 'package:hidi/features/users/repos/users_repos.dart';

class _FakeUserRepo extends UserRepository {
  _FakeUserRepo({this.patchResult = true, this.serverPushEnabled = false});

  final bool patchResult;
  final bool serverPushEnabled;
  final List<bool> patchedValues = [];

  @override
  Future<bool> patchPushEnabled(bool enabled) async {
    patchedValues.add(enabled);
    return patchResult;
  }

  @override
  Future<User?> getCurrentUser() async => User(
        id: 1,
        email: 'me@hibi.app',
        nickname: '나',
        roleType: 'USER',
        pushEnabled: serverPushEnabled,
      );
}

void main() {
  group('PushNotificationViewModel (실API 경로)', () {
    test('토글 성공 시 서버에 새 값을 저장하고 상태를 유지한다', () async {
      final repo = _FakeUserRepo();
      final viewModel =
          PushNotificationViewModel(useMock: false, userRepository: repo);

      await viewModel.toggle(); // 기본 true → false

      expect(repo.patchedValues, [false]);
      expect(viewModel.state.isEnabled, isFalse);
      expect(viewModel.state.isLoading, isFalse);
    });

    test('토글 실패 시 이전 상태로 롤백한다', () async {
      final repo = _FakeUserRepo(patchResult: false);
      final viewModel =
          PushNotificationViewModel(useMock: false, userRepository: repo);

      await viewModel.toggle();

      expect(viewModel.state.isEnabled, isTrue); // 롤백
    });

    test('loadSettings는 서버의 pushEnabled 값을 반영한다', () async {
      final repo = _FakeUserRepo(serverPushEnabled: false);
      final viewModel =
          PushNotificationViewModel(useMock: false, userRepository: repo);

      await viewModel.loadSettings();

      expect(viewModel.state.isEnabled, isFalse);
    });
  });

  group('User.fromJson', () {
    test('pushEnabled를 매핑하고 없으면 true가 기본값이다', () {
      final withFlag = User.fromJson(const {
        'id': 1,
        'email': 'a@b.c',
        'nickname': 'n',
        'pushEnabled': false,
      });
      final withoutFlag = User.fromJson(const {
        'id': 2,
        'email': 'a@b.c',
        'nickname': 'n',
      });

      expect(withFlag.pushEnabled, isFalse);
      expect(withoutFlag.pushEnabled, isTrue);
    });
  });
}
