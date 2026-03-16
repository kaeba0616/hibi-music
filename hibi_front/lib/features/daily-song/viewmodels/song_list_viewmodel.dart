import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/daily-song/models/song_model.dart';
import 'package:hidi/features/daily-song/repos/song_repo.dart';

class SongListViewmodel extends AsyncNotifier<List<Song>> {
  late final SongRepository _songRepo;
  @override
  FutureOr<List<Song>> build() {
    // TODO: implement build
    _songRepo = ref.read(songRepo);
    throw UnimplementedError();
  }

  Future<void> getSongs() async {
    state = AsyncValue.loading();
    final songs = await _songRepo.getSongs();
    state = AsyncValue.data(songs);
  }

  Future<void> getSongsByMonthAndYear(int month, int year) async {
    state = AsyncValue.loading();
    final songs = await _songRepo.getSongsByMonthAndYear(month, year);
    state = AsyncValue.data(songs);
  }
}

final songsProvider = AsyncNotifierProvider<SongListViewmodel, List<Song>>(
  () => SongListViewmodel(),
);
