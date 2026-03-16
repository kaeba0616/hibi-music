import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/artists/models/artist_model.dart';
import 'package:hidi/features/artists/repos/artist_repo.dart';

/// 아티스트 목록 필터 타입
enum ArtistFilterType {
  all,
  following,
}

/// 아티스트 목록 상태
class ArtistListState {
  final List<Artist> artists;
  final ArtistFilterType filterType;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  ArtistListState({
    this.artists = const [],
    this.filterType = ArtistFilterType.all,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  ArtistListState copyWith({
    List<Artist>? artists,
    ArtistFilterType? filterType,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return ArtistListState(
      artists: artists ?? this.artists,
      filterType: filterType ?? this.filterType,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 필터링된 아티스트 목록
  List<Artist> get filteredArtists {
    var result = artists;

    // 검색어 필터
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((a) {
        return a.nameKor.toLowerCase().contains(query) ||
            a.nameEng.toLowerCase().contains(query) ||
            a.nameJp.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }
}

class ArtistListViewModel extends Notifier<ArtistListState> {
  late final ArtistRepository _artistRepo;

  @override
  ArtistListState build() {
    _artistRepo = ref.read(artistRepoProvider);
    // 초기 데이터 로드
    Future.microtask(() => fetchArtists());
    return ArtistListState(isLoading: true);
  }

  /// 아티스트 목록 가져오기
  Future<void> fetchArtists() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final followingOnly = state.filterType == ArtistFilterType.following;
      final artists = await _artistRepo.getArtists(
        followingOnly: followingOnly,
      );
      state = state.copyWith(artists: artists, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '아티스트 목록을 불러올 수 없습니다',
      );
    }
  }

  /// 필터 변경
  void setFilter(ArtistFilterType filterType) {
    if (state.filterType != filterType) {
      state = state.copyWith(filterType: filterType);
      fetchArtists();
    }
  }

  /// 검색어 변경
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// 팔로우 토글 (낙관적 UI 업데이트)
  Future<void> toggleFollow(int artistId) async {
    final index = state.artists.indexWhere((a) => a.id == artistId);
    if (index == -1) return;

    final artist = state.artists[index];
    final wasFollowing = artist.isFollowing;

    // 낙관적 UI 업데이트
    final updatedArtist = artist.copyWith(
      isFollowing: !wasFollowing,
      followerCount: wasFollowing
          ? artist.followerCount - 1
          : artist.followerCount + 1,
    );
    final updatedList = List<Artist>.from(state.artists);
    updatedList[index] = updatedArtist;
    state = state.copyWith(artists: updatedList);

    // API 호출
    try {
      final success = wasFollowing
          ? await _artistRepo.unfollow(artistId)
          : await _artistRepo.follow(artistId);

      if (!success) {
        // 실패 시 롤백
        final rollbackList = List<Artist>.from(state.artists);
        rollbackList[index] = artist;
        state = state.copyWith(artists: rollbackList);
      }
    } catch (e) {
      // 에러 시 롤백
      final rollbackList = List<Artist>.from(state.artists);
      rollbackList[index] = artist;
      state = state.copyWith(artists: rollbackList);
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await fetchArtists();
  }
}

final artistListProvider =
    NotifierProvider<ArtistListViewModel, ArtistListState>(
  () => ArtistListViewModel(),
);
