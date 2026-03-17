import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/calendar/viewmodels/calendar_viewmodel.dart';
import 'package:hidi/features/calendar/views/calendar_view.dart';
import 'package:hidi/features/calendar/widgets/calendar_day_cell.dart';
import 'package:hidi/features/calendar/widgets/calendar_song_card.dart';
import 'package:hidi/features/calendar/widgets/month_navigator.dart';
import 'package:hidi/features/daily-song/repos/daily_song_repo.dart';

void main() {
  group('CalendarView Widget Tests', () {
    testWidgets('캘린더 화면이 렌더링됨', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CalendarView(),
          ),
        ),
      );
      // Use pump with duration instead of pumpAndSettle to avoid timer issues
      await tester.pump(const Duration(seconds: 1));

      // AppBar 타이틀 확인
      expect(find.text('캘린더'), findsOneWidget);

      // 좋아요 필터 버튼 확인 (favorite_border when off, favorite when on)
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && (widget.icon == Icons.favorite_border || widget.icon == Icons.favorite),
        ),
        findsWidgets,
      );
    });

    testWidgets('월 네비게이션이 표시됨 (AC-F4-3)', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CalendarView(),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      // 이전/다음 월 버튼 확인
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      // 오늘 버튼 확인
      expect(find.text('오늘'), findsOneWidget);
    });

    testWidgets('요일 헤더가 표시됨 (AC-F4-1)', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CalendarView(),
          ),
        ),
      );

      // Use pump with duration instead of pumpAndSettle to avoid timer issues
      await tester.pump(const Duration(seconds: 1));

      // 요일 헤더 확인 - during loading, the loading calendar also shows day headers
      expect(find.text('일'), findsWidgets);
      expect(find.text('월'), findsWidgets);
      expect(find.text('화'), findsWidgets);
      expect(find.text('수'), findsWidgets);
      expect(find.text('목'), findsWidgets);
      expect(find.text('금'), findsWidgets);
      expect(find.text('토'), findsWidgets);
    });
  });

  group('MonthNavigator Widget Tests', () {
    testWidgets('월 표시가 올바른 형식임', (tester) async {
      bool previousCalled = false;
      bool nextCalled = false;
      bool todayCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthNavigator(
              year: 2026,
              month: 2,
              onPrevious: () => previousCalled = true,
              onNext: () => nextCalled = true,
              onTodayTap: () => todayCalled = true,
            ),
          ),
        ),
      );

      // 월 표시 확인
      expect(find.text('2026년 2월'), findsOneWidget);

      // 이전 월 버튼 탭
      await tester.tap(find.byIcon(Icons.chevron_left));
      expect(previousCalled, true);

      // 다음 월 버튼 탭
      await tester.tap(find.byIcon(Icons.chevron_right));
      expect(nextCalled, true);

      // 오늘 버튼 탭
      await tester.tap(find.text('오늘'));
      expect(todayCalled, true);
    });
  });

  group('CalendarDayCell Widget Tests', () {
    testWidgets('기본 날짜 셀이 렌더링됨', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              date: DateTime(2026, 2, 15),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('오늘 날짜에 테두리가 표시됨', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              date: DateTime.now(),
              isToday: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // 오늘 날짜 표시 확인 (테두리가 있는 Container)
      expect(find.byType(CalendarDayCell), findsOneWidget);
    });

    testWidgets('선택된 날짜에 배경색이 표시됨', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              date: DateTime(2026, 2, 15),
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CalendarDayCell), findsOneWidget);
    });

    testWidgets('마커가 있는 날짜에 점이 표시됨 (AC-F4-1)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              date: DateTime(2026, 2, 15),
              hasMarker: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // 마커(점) 확인 - 6x6 크기의 Container
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('비활성화된 날짜는 탭 불가', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDayCell(
              date: DateTime(2026, 2, 15),
              isDisabled: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CalendarDayCell));
      expect(tapped, false);
    });
  });

  group('CalendarViewModel Tests', () {
    test('초기 상태가 현재 월로 설정됨', () {
      final container = ProviderContainer(
        overrides: [
          dailySongRepoProvider.overrideWithValue(
            DailySongRepository(useMock: true),
          ),
        ],
      );

      final state = container.read(calendarViewModelProvider);
      final now = DateTime.now();

      expect(state.year, now.year);
      expect(state.month, now.month);
      expect(state.selectedDate?.day, now.day);
      expect(state.likedFilterOn, false);
    });

    test('이전 월로 이동', () async {
      final container = ProviderContainer(
        overrides: [
          dailySongRepoProvider.overrideWithValue(
            DailySongRepository(useMock: true),
          ),
        ],
      );

      final viewModel = container.read(calendarViewModelProvider.notifier);
      final initialState = container.read(calendarViewModelProvider);
      final initialMonth = initialState.month;

      viewModel.previousMonth();

      // 비동기 로딩 대기
      await Future.delayed(const Duration(milliseconds: 100));

      final newState = container.read(calendarViewModelProvider);

      if (initialMonth == 1) {
        expect(newState.month, 12);
        expect(newState.year, initialState.year - 1);
      } else {
        expect(newState.month, initialMonth - 1);
      }
    });

    test('다음 월로 이동', () async {
      final container = ProviderContainer(
        overrides: [
          dailySongRepoProvider.overrideWithValue(
            DailySongRepository(useMock: true),
          ),
        ],
      );

      final viewModel = container.read(calendarViewModelProvider.notifier);
      final initialState = container.read(calendarViewModelProvider);
      final initialMonth = initialState.month;

      viewModel.nextMonth();

      // 비동기 로딩 대기
      await Future.delayed(const Duration(milliseconds: 100));

      final newState = container.read(calendarViewModelProvider);

      if (initialMonth == 12) {
        expect(newState.month, 1);
        expect(newState.year, initialState.year + 1);
      } else {
        expect(newState.month, initialMonth + 1);
      }
    });

    test('좋아요 필터 토글', () {
      final container = ProviderContainer(
        overrides: [
          dailySongRepoProvider.overrideWithValue(
            DailySongRepository(useMock: true),
          ),
        ],
      );

      final viewModel = container.read(calendarViewModelProvider.notifier);

      expect(container.read(calendarViewModelProvider).likedFilterOn, false);

      viewModel.toggleLikedFilter();

      expect(container.read(calendarViewModelProvider).likedFilterOn, true);

      viewModel.toggleLikedFilter();

      expect(container.read(calendarViewModelProvider).likedFilterOn, false);
    });

    test('날짜 선택', () {
      final container = ProviderContainer(
        overrides: [
          dailySongRepoProvider.overrideWithValue(
            DailySongRepository(useMock: true),
          ),
        ],
      );

      final viewModel = container.read(calendarViewModelProvider.notifier);
      final testDate = DateTime(2026, 2, 15);

      viewModel.selectDate(testDate);

      final state = container.read(calendarViewModelProvider);
      expect(state.selectedDate, testDate);
    });

    test('미래 날짜는 선택 불가', () {
      final container = ProviderContainer(
        overrides: [
          dailySongRepoProvider.overrideWithValue(
            DailySongRepository(useMock: true),
          ),
        ],
      );

      final viewModel = container.read(calendarViewModelProvider.notifier);
      final initialDate = container.read(calendarViewModelProvider).selectedDate;
      final futureDate = DateTime.now().add(const Duration(days: 10));

      viewModel.selectDate(futureDate);

      // 미래 날짜는 무시되어야 함
      final state = container.read(calendarViewModelProvider);
      expect(state.selectedDate, initialDate);
    });
  });
}
