import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';
import 'package:hidi/features/daily-song/mocks/related_songs_mock.dart';

/// 좋아요 곡 목록 상태 (F15)
class LikedSongsState {
  final List<DailySong> songs;
  final bool isLoading;
  final String? error;

  const LikedSongsState({
    this.songs = const [],
    this.isLoading = false,
    this.error,
  });

  LikedSongsState copyWith({
    List<DailySong>? songs,
    bool? isLoading,
    String? error,
  }) {
    return LikedSongsState(
      songs: songs ?? this.songs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LikedSongsViewModel extends StateNotifier<LikedSongsState> {
  LikedSongsViewModel() : super(const LikedSongsState());

  Future<void> loadLikedSongs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final songs = await getMockLikedSongsWithDelay();
      state = state.copyWith(songs: songs, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: '좋아요 곡을 불러올 수 없습니다',
        isLoading: false,
      );
    }
  }

  void removeLike(int songId) {
    final updated = state.songs.where((s) => s.id != songId).toList();
    state = state.copyWith(songs: updated);
  }
}

final likedSongsViewModelProvider =
    StateNotifierProvider<LikedSongsViewModel, LikedSongsState>(
  (ref) => LikedSongsViewModel(),
);
