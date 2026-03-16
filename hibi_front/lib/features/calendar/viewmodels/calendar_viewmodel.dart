import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';
import 'package:hidi/features/daily-song/repos/daily_song_repo.dart';

/// 캘린더 상태
class CalendarState {
  final int year;
  final int month;
  final DateTime? selectedDate;
  final List<DailySong> songs;
  final bool isLoading;
  final String? error;
  final bool likedFilterOn;

  CalendarState({
    required this.year,
    required this.month,
    this.selectedDate,
    this.songs = const [],
    this.isLoading = false,
    this.error,
    this.likedFilterOn = false,
  });

  /// 초기 상태 (현재 월)
  factory CalendarState.initial() {
    final now = DateTime.now();
    return CalendarState(
      year: now.year,
      month: now.month,
      selectedDate: now,
    );
  }

  CalendarState copyWith({
    int? year,
    int? month,
    DateTime? selectedDate,
    List<DailySong>? songs,
    bool? isLoading,
    String? error,
    bool? likedFilterOn,
    bool clearSelectedDate = false,
  }) {
    return CalendarState(
      year: year ?? this.year,
      month: month ?? this.month,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      songs: songs ?? this.songs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      likedFilterOn: likedFilterOn ?? this.likedFilterOn,
    );
  }

  /// 마커가 표시될 날짜들 (필터 적용)
  Set<DateTime> get markedDates {
    final filtered = likedFilterOn
        ? songs.where((s) => s.isLiked).toList()
        : songs;

    return filtered.map((s) => DateTime(
      s.recommendedDate.year,
      s.recommendedDate.month,
      s.recommendedDate.day,
    )).toSet();
  }

  /// 선택된 날짜의 노래
  DailySong? get selectedSong {
    if (selectedDate == null) return null;

    try {
      return songs.firstWhere((s) =>
        s.recommendedDate.year == selectedDate!.year &&
        s.recommendedDate.month == selectedDate!.month &&
        s.recommendedDate.day == selectedDate!.day,
      );
    } catch (e) {
      return null;
    }
  }

  /// 좋아요한 노래가 있는지
  bool get hasLikedSongs => songs.any((s) => s.isLiked);
}

/// 캘린더 ViewModel
class CalendarViewModel extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    // 초기 로드
    Future.microtask(() => loadMonth(state.year, state.month));
    return CalendarState.initial();
  }

  DailySongRepository get _repo => ref.read(dailySongRepoProvider);

  /// 월별 데이터 로드
  Future<void> loadMonth(int year, int month) async {
    state = state.copyWith(
      year: year,
      month: month,
      isLoading: true,
      error: null,
    );

    try {
      final songs = await _repo.getSongsByMonth(year, month);
      state = state.copyWith(
        songs: songs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '캘린더를 불러올 수 없습니다',
      );
    }
  }

  /// 이전 월로 이동
  void previousMonth() {
    int newYear = state.year;
    int newMonth = state.month - 1;

    if (newMonth < 1) {
      newMonth = 12;
      newYear--;
    }

    loadMonth(newYear, newMonth);
  }

  /// 다음 월로 이동
  void nextMonth() {
    int newYear = state.year;
    int newMonth = state.month + 1;

    if (newMonth > 12) {
      newMonth = 1;
      newYear++;
    }

    loadMonth(newYear, newMonth);
  }

  /// 오늘로 이동
  void goToToday() {
    final now = DateTime.now();
    state = state.copyWith(selectedDate: now);
    loadMonth(now.year, now.month);
  }

  /// 날짜 선택
  void selectDate(DateTime date) {
    // 미래 날짜는 선택 불가
    if (date.isAfter(DateTime.now())) return;

    state = state.copyWith(selectedDate: date);
  }

  /// 좋아요 필터 토글
  void toggleLikedFilter() {
    state = state.copyWith(likedFilterOn: !state.likedFilterOn);
  }

  /// 좋아요 토글
  Future<void> toggleLike(int songId) async {
    // 낙관적 업데이트
    final updatedSongs = state.songs.map((song) {
      if (song.id == songId) {
        return song.copyWith(
          isLiked: !song.isLiked,
          likeCount: song.isLiked ? song.likeCount - 1 : song.likeCount + 1,
        );
      }
      return song;
    }).toList();

    state = state.copyWith(songs: updatedSongs);

    // API 호출
    final success = await _repo.toggleLike(songId);

    if (!success) {
      // 실패 시 롤백
      await loadMonth(state.year, state.month);
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadMonth(state.year, state.month);
  }
}

/// Calendar ViewModel Provider
final calendarViewModelProvider =
    NotifierProvider<CalendarViewModel, CalendarState>(
  () => CalendarViewModel(),
);
