import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';
import 'package:hidi/features/daily-song/repos/daily_song_repo.dart';

/// 오늘의 노래 상태
class DailySongState {
  final DailySong? song;
  final bool isLoading;
  final String? error;

  const DailySongState({
    this.song,
    this.isLoading = false,
    this.error,
  });

  DailySongState copyWith({
    DailySong? song,
    bool? isLoading,
    String? error,
  }) {
    return DailySongState(
      song: song ?? this.song,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isEmpty => song == null && !isLoading && error == null;
  bool get hasError => error != null;
  bool get hasData => song != null;
}

/// 오늘의 노래 ViewModel
class DailySongViewModel extends StateNotifier<DailySongState> {
  final DailySongRepository _repo;

  DailySongViewModel(this._repo) : super(const DailySongState());

  /// 오늘의 노래 가져오기
  Future<void> fetchTodaySong() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final song = await _repo.getTodaySong();
      state = DailySongState(song: song, isLoading: false);
    } catch (e) {
      state = DailySongState(
        isLoading: false,
        error: '노래를 불러오는데 실패했습니다',
      );
    }
  }

  /// 좋아요 토글 (낙관적 UI 업데이트)
  Future<void> toggleLike() async {
    final currentSong = state.song;
    if (currentSong == null) return;

    // 낙관적 UI 업데이트
    final newIsLiked = !currentSong.isLiked;
    final newLikeCount =
        currentSong.likeCount + (newIsLiked ? 1 : -1);

    state = state.copyWith(
      song: currentSong.copyWith(
        isLiked: newIsLiked,
        likeCount: newLikeCount,
      ),
    );

    // API 호출
    final success = await _repo.toggleLike(currentSong.id);

    // 실패 시 롤백
    if (!success) {
      state = state.copyWith(song: currentSong);
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await fetchTodaySong();
  }
}

/// 오늘의 노래 Provider
final dailySongViewModelProvider =
    StateNotifierProvider<DailySongViewModel, DailySongState>((ref) {
  final repo = ref.watch(dailySongRepoProvider);
  return DailySongViewModel(repo);
});

/// 노래 상세 ViewModel (ID로 조회)
class SongDetailViewModel extends StateNotifier<DailySongState> {
  final DailySongRepository _repo;

  SongDetailViewModel(this._repo) : super(const DailySongState());

  /// ID로 노래 가져오기
  Future<void> fetchSongById(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final song = await _repo.getSongById(id);
      state = DailySongState(song: song, isLoading: false);
    } catch (e) {
      state = DailySongState(
        isLoading: false,
        error: '노래 정보를 불러오는데 실패했습니다',
      );
    }
  }

  /// 좋아요 토글
  Future<void> toggleLike() async {
    final currentSong = state.song;
    if (currentSong == null) return;

    final newIsLiked = !currentSong.isLiked;
    final newLikeCount =
        currentSong.likeCount + (newIsLiked ? 1 : -1);

    state = state.copyWith(
      song: currentSong.copyWith(
        isLiked: newIsLiked,
        likeCount: newLikeCount,
      ),
    );

    final success = await _repo.toggleLike(currentSong.id);

    if (!success) {
      state = state.copyWith(song: currentSong);
    }
  }
}

/// 노래 상세 Provider (family로 songId 받음)
final songDetailViewModelProvider = StateNotifierProvider.family<
    SongDetailViewModel, DailySongState, int>((ref, songId) {
  final repo = ref.watch(dailySongRepoProvider);
  final viewModel = SongDetailViewModel(repo);
  // 자동으로 데이터 로드
  viewModel.fetchSongById(songId);
  return viewModel;
});
