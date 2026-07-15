import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/authentication/repos/authentication_repo.dart';
import 'package:hidi/features/follow/models/follow_models.dart';
import 'package:hidi/features/follow/repos/follow_repo.dart';
import 'package:hidi/features/users/models/user.dart';
import 'package:hidi/features/users/repos/users_repos.dart';
import 'package:hidi/features/users/views/user_profile_view.dart';

import '../../utils/test_app.dart';

class _FakeAuthRepo extends AuthenticationRepository {
  @override
  bool get isLoggedIn => true;
}

class _FakeUserRepo extends UserRepository {
  @override
  Future<User?> getCurrentUser() async =>
      User(id: 5, email: 'real@hibi.app', nickname: '실제닉네임', roleType: 'USER');
}

class _FakeFollowRepo extends FollowRepository {
  _FakeFollowRepo() : super(useMock: false);

  @override
  Future<UserProfile?> getUserProfile(int userId) async => UserProfile(
        id: userId,
        nickname: '실제닉네임',
        username: 'real',
        profileImage: null,
        postCount: 2,
        followerCount: 7,
        followingCount: 3,
        isFollowing: false,
      );
}

void main() {
  group('MyPageView', () {
    testWidgets('내 프로필과 팔로워/팔로잉 수를 실제 데이터로 표시한다', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const MyPageView(),
          overrides: [
            authRepo.overrideWithValue(_FakeAuthRepo()),
            userRepo.overrideWithValue(_FakeUserRepo()),
            followRepoProvider.overrideWithValue(_FakeFollowRepo()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // 실제 닉네임 표시 (아바타 이니셜 + 앱바)
      expect(find.text('실제닉네임'), findsWidgets);
      // 실제 팔로워/팔로잉 수
      expect(find.text('7'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // 하드코딩 mock 값이 사라져야 한다
      expect(find.text('Hidi'), findsNothing);
      expect(find.text('1337'), findsNothing);
      expect(find.text('42'), findsNothing);
      expect(find.text('128 songs'), findsNothing);
    });
  });
}
