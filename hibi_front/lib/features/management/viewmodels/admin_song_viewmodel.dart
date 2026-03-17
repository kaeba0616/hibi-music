/// F18 관리자 곡 등록 ViewModel

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/admin_song_models.dart';
import '../mocks/admin_song_mock.dart';
import '../repos/admin_repo.dart';

/// 곡 등록 폼 상태
class SongRegisterState {
  final String titleKor;
  final String titleEng;
  final String titleJp;
  final ArtistSuggestion? selectedArtist;
  final String story;
  final String lyricsJp;
  final String lyricsKr;
  final String youtubeUrl;
  final List<RelatedSongEntry> relatedSongs;
  final List<ArtistSuggestion> artistSuggestions;
  final List<SongSearchResult> songSearchResults;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const SongRegisterState({
    this.titleKor = '',
    this.titleEng = '',
    this.titleJp = '',
    this.selectedArtist,
    this.story = '',
    this.lyricsJp = '',
    this.lyricsKr = '',
    this.youtubeUrl = '',
    this.relatedSongs = const [],
    this.artistSuggestions = const [],
    this.songSearchResults = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  SongRegisterState copyWith({
    String? titleKor,
    String? titleEng,
    String? titleJp,
    ArtistSuggestion? selectedArtist,
    String? story,
    String? lyricsJp,
    String? lyricsKr,
    String? youtubeUrl,
    List<RelatedSongEntry>? relatedSongs,
    List<ArtistSuggestion>? artistSuggestions,
    List<SongSearchResult>? songSearchResults,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearArtist = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SongRegisterState(
      titleKor: titleKor ?? this.titleKor,
      titleEng: titleEng ?? this.titleEng,
      titleJp: titleJp ?? this.titleJp,
      selectedArtist:
          clearArtist ? null : (selectedArtist ?? this.selectedArtist),
      story: story ?? this.story,
      lyricsJp: lyricsJp ?? this.lyricsJp,
      lyricsKr: lyricsKr ?? this.lyricsKr,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      relatedSongs: relatedSongs ?? this.relatedSongs,
      artistSuggestions: artistSuggestions ?? this.artistSuggestions,
      songSearchResults: songSearchResults ?? this.songSearchResults,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  bool get isFormValid =>
      titleKor.isNotEmpty && titleJp.isNotEmpty && selectedArtist != null;
}

/// 연관곡 엔트리 (UI 전용)
class RelatedSongEntry {
  final SongSearchResult song;
  final String reason;

  const RelatedSongEntry({required this.song, this.reason = ''});

  RelatedSongEntry copyWith({String? reason}) {
    return RelatedSongEntry(song: song, reason: reason ?? this.reason);
  }
}

/// 곡 등록 ViewModel
class SongRegisterViewModel extends StateNotifier<SongRegisterState> {
  final AdminRepository _repository;

  SongRegisterViewModel(this._repository) : super(const SongRegisterState());

  void updateTitleKor(String value) =>
      state = state.copyWith(titleKor: value);
  void updateTitleEng(String value) =>
      state = state.copyWith(titleEng: value);
  void updateTitleJp(String value) => state = state.copyWith(titleJp: value);
  void updateStory(String value) => state = state.copyWith(story: value);
  void updateLyricsJp(String value) =>
      state = state.copyWith(lyricsJp: value);
  void updateLyricsKr(String value) =>
      state = state.copyWith(lyricsKr: value);
  void updateYoutubeUrl(String value) =>
      state = state.copyWith(youtubeUrl: value);

  void selectArtist(ArtistSuggestion artist) {
    state = state.copyWith(selectedArtist: artist);
  }

  void clearArtist() {
    state = state.copyWith(clearArtist: true);
  }

  /// 아티스트 검색 (자동완성)
  Future<void> searchArtists(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(artistSuggestions: []);
      return;
    }

    // Mock 모드 - 로컬 필터링
    final lowerQuery = query.toLowerCase();
    final results = mockArtistSuggestions.where((a) {
      return a.nameKor.toLowerCase().contains(lowerQuery) ||
          (a.nameEng?.toLowerCase().contains(lowerQuery) ?? false) ||
          (a.nameJp?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    state = state.copyWith(artistSuggestions: results);
  }

  /// 곡 검색 (연관곡 추가용)
  Future<void> searchSongs(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(songSearchResults: []);
      return;
    }

    final lowerQuery = query.toLowerCase();
    final results = mockSongSearchResults.where((s) {
      return s.titleKor.toLowerCase().contains(lowerQuery) ||
          s.titleJp.toLowerCase().contains(lowerQuery) ||
          s.artistName.toLowerCase().contains(lowerQuery);
    }).toList();

    state = state.copyWith(songSearchResults: results);
  }

  /// 연관곡 추가
  void addRelatedSong(SongSearchResult song) {
    if (state.relatedSongs.any((e) => e.song.id == song.id)) return;

    final entry = RelatedSongEntry(song: song);
    state = state.copyWith(
      relatedSongs: [...state.relatedSongs, entry],
    );
  }

  /// 연관곡 이유 업데이트
  void updateRelatedSongReason(int index, String reason) {
    final updated = List<RelatedSongEntry>.from(state.relatedSongs);
    updated[index] = updated[index].copyWith(reason: reason);
    state = state.copyWith(relatedSongs: updated);
  }

  /// 연관곡 제거
  void removeRelatedSong(int index) {
    final updated = List<RelatedSongEntry>.from(state.relatedSongs);
    updated.removeAt(index);
    state = state.copyWith(relatedSongs: updated);
  }

  /// 곡 저장
  Future<void> saveSong() async {
    if (!state.isFormValid) {
      state = state.copyWith(errorMessage: '필수 항목을 입력해주세요');
      return;
    }

    state = state.copyWith(isSaving: true, clearError: true, clearSuccess: true);

    try {
      await _repository.createAdminSong(
        AdminSongCreateRequest(
          titleKor: state.titleKor,
          titleEng: state.titleEng.isNotEmpty ? state.titleEng : null,
          titleJp: state.titleJp,
          artistId: state.selectedArtist!.id,
          story: state.story.isNotEmpty ? state.story : null,
          lyricsJp: state.lyricsJp.isNotEmpty ? state.lyricsJp : null,
          lyricsKr: state.lyricsKr.isNotEmpty ? state.lyricsKr : null,
          youtubeUrl: state.youtubeUrl.isNotEmpty ? state.youtubeUrl : null,
          relatedSongs: state.relatedSongs
              .where((e) => e.reason.isNotEmpty)
              .map((e) => RelatedSongInput(
                    relatedSongId: e.song.id,
                    reason: e.reason,
                  ))
              .toList(),
        ),
      );

      state = state.copyWith(
        isSaving: false,
        successMessage: '곡이 등록되었습니다',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: '곡 등록에 실패했습니다',
      );
    }
  }
}

/// 곡 등록 ViewModel Provider
final songRegisterViewModelProvider =
    StateNotifierProvider<SongRegisterViewModel, SongRegisterState>((ref) {
  final repository = ref.watch(adminRepoProvider);
  return SongRegisterViewModel(repository);
});
