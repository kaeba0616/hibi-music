import 'package:flutter_test/flutter_test.dart';
import 'package:hidi/features/daily-song/mocks/related_songs_mock.dart';
import 'package:hidi/features/daily-song/models/daily_song_model.dart';
import 'package:hidi/features/daily-song/repos/daily_song_repo.dart';
import 'package:hidi/features/daily-song/viewmodels/liked_songs_viewmodel.dart';

class _FakeDailySongRepo extends DailySongRepository {
  _FakeDailySongRepo({this.toggleResult = true}) : super(useMock: false);

  final bool toggleResult;
  final List<int> toggledSongIds = [];

  @override
  Future<List<DailySong>> getLikedSongs() async =>
      mockLikedSongs.take(2).toList();

  @override
  Future<bool> toggleLike(int songId) async {
    toggledSongIds.add(songId);
    return toggleResult;
  }
}

void main() {
  group('LikedSongsViewModel (실API 경로)', () {
    test('레포지토리에서 좋아요 곡 목록을 불러온다', () async {
      final viewModel = LikedSongsViewModel(_FakeDailySongRepo());

      await viewModel.loadLikedSongs();

      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.songs, hasLength(2));
    });

    test('removeLike는 서버 토글 성공 시 목록에서 곡을 제거한다', () async {
      final repo = _FakeDailySongRepo();
      final viewModel = LikedSongsViewModel(repo);
      await viewModel.loadLikedSongs();
      final firstId = viewModel.state.songs.first.id;

      await viewModel.removeLike(firstId);

      expect(repo.toggledSongIds, [firstId]);
      expect(viewModel.state.songs.map((s) => s.id), isNot(contains(firstId)));
      expect(viewModel.state.songs, hasLength(1));
    });

    test('removeLike는 서버 토글 실패 시 목록을 유지한다', () async {
      final repo = _FakeDailySongRepo(toggleResult: false);
      final viewModel = LikedSongsViewModel(repo);
      await viewModel.loadLikedSongs();
      final firstId = viewModel.state.songs.first.id;

      await viewModel.removeLike(firstId);

      expect(viewModel.state.songs, hasLength(2));
    });
  });
}
