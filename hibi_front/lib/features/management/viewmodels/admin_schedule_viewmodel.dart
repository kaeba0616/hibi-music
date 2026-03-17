/// F18 관리자 예약 게시 ViewModel

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/admin_song_models.dart';
import '../mocks/admin_song_mock.dart';
import '../repos/admin_repo.dart';

/// 예약 게시 상태
class SchedulePublishState {
  final List<SongSearchResult> availableSongs;
  final SongSearchResult? selectedSong;
  final DateTime? selectedDate;
  final int selectedHour;
  final int selectedMinute;
  final List<ScheduledSongItem> scheduledSongs;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const SchedulePublishState({
    this.availableSongs = const [],
    this.selectedSong,
    this.selectedDate,
    this.selectedHour = 9,
    this.selectedMinute = 0,
    this.scheduledSongs = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  SchedulePublishState copyWith({
    List<SongSearchResult>? availableSongs,
    SongSearchResult? selectedSong,
    DateTime? selectedDate,
    int? selectedHour,
    int? selectedMinute,
    List<ScheduledSongItem>? scheduledSongs,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearSong = false,
    bool clearDate = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SchedulePublishState(
      availableSongs: availableSongs ?? this.availableSongs,
      selectedSong: clearSong ? null : (selectedSong ?? this.selectedSong),
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
      selectedHour: selectedHour ?? this.selectedHour,
      selectedMinute: selectedMinute ?? this.selectedMinute,
      scheduledSongs: scheduledSongs ?? this.scheduledSongs,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  bool get canSchedule =>
      selectedSong != null && selectedDate != null;

  DateTime? get scheduledDateTime {
    if (selectedDate == null) return null;
    return DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedHour,
      selectedMinute,
    );
  }
}

/// 예약 게시 ViewModel
class SchedulePublishViewModel extends StateNotifier<SchedulePublishState> {
  final AdminRepository _repository;

  SchedulePublishViewModel(this._repository)
      : super(const SchedulePublishState());

  /// 초기 데이터 로드
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Mock 모드
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(
        availableSongs: mockSongSearchResults,
        scheduledSongs: mockScheduledSongs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '데이터를 불러오는데 실패했습니다',
      );
    }
  }

  void selectSong(SongSearchResult song) {
    state = state.copyWith(selectedSong: song);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void selectTime(int hour, int minute) {
    state = state.copyWith(selectedHour: hour, selectedMinute: minute);
  }

  /// 예약 게시
  Future<void> schedulePublish() async {
    if (!state.canSchedule) {
      state = state.copyWith(errorMessage: '곡과 날짜를 선택해주세요');
      return;
    }

    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);

    try {
      await _repository.scheduleSongPublish(
        SchedulePublishRequest(
          songId: state.selectedSong!.id,
          scheduledAt: state.scheduledDateTime!,
        ),
      );

      // Mock: 목록에 추가
      final newItem = ScheduledSongItem(
        id: state.scheduledSongs.length + 10,
        songId: state.selectedSong!.id,
        songTitle: state.selectedSong!.titleKor,
        artistName: state.selectedSong!.artistName,
        scheduledAt: state.scheduledDateTime!,
        status: ScheduleStatus.pending,
      );

      state = state.copyWith(
        scheduledSongs: [newItem, ...state.scheduledSongs],
        isSaving: false,
        successMessage: '예약이 등록되었습니다',
        clearSong: true,
        clearDate: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: '예약 등록에 실패했습니다',
      );
    }
  }

  /// 예약 취소
  Future<void> cancelSchedule(int scheduleId) async {
    try {
      await _repository.cancelScheduledPublish(scheduleId);

      final updated = state.scheduledSongs.map((item) {
        if (item.id == scheduleId) {
          return ScheduledSongItem(
            id: item.id,
            songId: item.songId,
            songTitle: item.songTitle,
            artistName: item.artistName,
            scheduledAt: item.scheduledAt,
            status: ScheduleStatus.cancelled,
          );
        }
        return item;
      }).toList();

      state = state.copyWith(
        scheduledSongs: updated,
        successMessage: '예약이 취소되었습니다',
      );
    } catch (e) {
      state = state.copyWith(errorMessage: '예약 취소에 실패했습니다');
    }
  }
}

/// 예약 게시 ViewModel Provider
final schedulePublishViewModelProvider =
    StateNotifierProvider<SchedulePublishViewModel, SchedulePublishState>(
        (ref) {
  final repository = ref.watch(adminRepoProvider);
  return SchedulePublishViewModel(repository);
});
