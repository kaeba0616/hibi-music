import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';
import 'package:hidi/features/daily-song/repos/daily_song_repo.dart';
import 'package:hidi/features/daily-song/views/home_view.dart';
import 'package:hidi/features/daily-song/views/widgets/empty_song_view.dart';
import 'package:hidi/features/main-screen/views/main_navigation_view.dart';

import '../../utils/test_app.dart';

class _NullSongRepo extends DailySongRepository {
  _NullSongRepo() : super(useMock: false);

  @override
  Future<DailySong?> getTodaySong() async => null;
}

void main() {
  group('HomeView 레이아웃', () {
    testWidgets('오늘의 곡 카드는 화면 가로 중앙에 배치된다', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const HomeView(),
          overrides: [
            dailySongRepoProvider.overrideWithValue(_NullSongRepo()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptySongView), findsOneWidget);

      final screenWidth = tester.getSize(find.byType(HomeView)).width;
      final cardCenterX = tester.getCenter(find.byType(EmptySongView)).dx;

      expect(
        cardCenterX,
        closeTo(screenWidth / 2, 1.0),
        reason: '본문 Column이 화면 폭을 채우지 못하면 카드가 왼쪽으로 쏠린다',
      );
    });

    testWidgets('실제 탭 구조(MainNavigationView) 안에서도 카드가 가로 중앙에 온다',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const MainNavigationView(tab: 'daily-song'),
          overrides: [
            dailySongRepoProvider.overrideWithValue(_NullSongRepo()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptySongView), findsOneWidget);

      final screenWidth =
          tester.getSize(find.byType(MainNavigationView)).width;
      final cardCenterX = tester.getCenter(find.byType(EmptySongView)).dx;

      expect(
        cardCenterX,
        closeTo(screenWidth / 2, 1.0),
        reason: 'Stack/Offstage로 감싸인 실제 탭 구조에서 쏠림이 재현될 수 있다',
      );
    });
  });
}
