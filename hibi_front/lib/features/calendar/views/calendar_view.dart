import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hidi/features/calendar/viewmodels/calendar_viewmodel.dart';
import 'package:hidi/features/calendar/widgets/calendar_empty_view.dart';
import 'package:hidi/features/calendar/widgets/calendar_grid.dart';
import 'package:hidi/features/calendar/widgets/calendar_song_card.dart';
import 'package:hidi/features/calendar/widgets/month_navigator.dart';

/// 캘린더 화면 (CA-01)
/// AC-F4-1: 월별 캘린더 표시
/// AC-F4-2: 날짜 선택
/// AC-F4-3: 월 변경
/// AC-F4-4: 좋아요 필터
class CalendarView extends ConsumerWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarViewModelProvider);
    final viewModel = ref.read(calendarViewModelProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
        centerTitle: true,
        actions: [
          // 좋아요 필터 버튼 (AC-F4-4)
          IconButton(
            icon: Icon(
              state.likedFilterOn ? Icons.favorite : Icons.favorite_border,
              color: state.likedFilterOn ? Colors.red : null,
            ),
            onPressed: viewModel.toggleLikedFilter,
            tooltip: state.likedFilterOn ? '전체 보기' : '좋아요만 보기',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // 월 네비게이션 (AC-F4-3)
              MonthNavigator(
                year: state.year,
                month: state.month,
                onPrevious: viewModel.previousMonth,
                onNext: viewModel.nextMonth,
                onTodayTap: viewModel.goToToday,
              ),

              // 캘린더 그리드 (AC-F4-1)
              if (state.isLoading)
                _buildLoadingCalendar(context)
              else if (state.error != null)
                _buildErrorView(context, state.error!, viewModel.refresh)
              else
                CalendarGrid(
                  year: state.year,
                  month: state.month,
                  selectedDate: state.selectedDate,
                  markedDates: state.markedDates,
                  likedDates: state.songs
                      .where((s) => s.isLiked)
                      .map((s) => DateTime(
                            s.recommendedDate.year,
                            s.recommendedDate.month,
                            s.recommendedDate.day,
                          ))
                      .toSet(),
                  onDateSelected: viewModel.selectDate,
                ),

              const Divider(height: 1),

              // 선택된 날짜의 노래 (AC-F4-2)
              _buildSelectedSongSection(context, ref, state, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  /// 로딩 상태의 캘린더 (Shimmer 효과)
  Widget _buildLoadingCalendar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 요일 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['일', '월', '화', '수', '목', '금', '토']
                .map((d) => SizedBox(
                      width: 40,
                      child: Text(d, textAlign: TextAlign.center),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          // Shimmer 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 에러 상태 뷰
  Widget _buildErrorView(
      BuildContext context, String error, VoidCallback onRetry) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '\u26A0\uFE0F', // ⚠️
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 선택된 날짜의 노래 섹션
  Widget _buildSelectedSongSection(
    BuildContext context,
    WidgetRef ref,
    CalendarState state,
    CalendarViewModel viewModel,
  ) {
    // 좋아요 필터 ON인데 좋아요한 노래가 없는 경우
    if (state.likedFilterOn && !state.hasLikedSongs) {
      return const CalendarEmptyView(type: CalendarEmptyType.noLikedSongs);
    }

    // 날짜가 선택되지 않은 경우
    if (state.selectedDate == null) {
      return const CalendarEmptyView(type: CalendarEmptyType.noSongForDate);
    }

    // 선택된 날짜의 노래가 없는 경우
    final song = state.selectedSong;
    if (song == null) {
      return const CalendarEmptyView(type: CalendarEmptyType.noSongForDate);
    }

    // 좋아요 필터가 ON인데 해당 노래가 좋아요 안 된 경우
    if (state.likedFilterOn && !song.isLiked) {
      return const CalendarEmptyView(type: CalendarEmptyType.noSongForDate);
    }

    // 노래 카드 표시
    return CalendarSongCard(
      song: song,
      onTap: () {
        // 노래 상세 화면으로 이동 (F2 DS-02)
        context.push('/songs/${song.id}');
      },
      onArtistTap: () {
        // 아티스트 상세 화면으로 이동 (F3 AR-02)
        context.push('/artists/${song.artist.id}');
      },
      onLikeTap: () {
        viewModel.toggleLike(song.id);
      },
    );
  }
}
