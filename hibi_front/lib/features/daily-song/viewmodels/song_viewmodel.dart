import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/daily-song/models/song_model.dart';
import 'package:hidi/features/daily-song/repos/song_repo.dart';

class SongViewmodel extends AsyncNotifier<Song> {
  late final SongRepository _songRepo;
  @override
  FutureOr<Song> build() {
    // TODO: implement build
    _songRepo = ref.read(songRepo);
    throw UnimplementedError();
  }

  Future<void> getSongById(int id) async {
    state = AsyncValue.loading();
    final song = await _songRepo.getSongById(id);
    state = AsyncValue.data(song);
  }

  Future<void> getSongByDate(String date) async {
    state = AsyncValue.loading();
    final song = await _songRepo.getSongByDate(date);
    state = AsyncValue.data(song);
  }
}

final songProvider = AsyncNotifierProvider<SongViewmodel, Song>(
  () => SongViewmodel(),
);
