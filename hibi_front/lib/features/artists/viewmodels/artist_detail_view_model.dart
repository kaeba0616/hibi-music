import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidi/features/artists/models/artist_detail_model.dart';
import 'package:hidi/features/artists/repos/artist_repo.dart';

/// 아티스트 상세 상태
class ArtistDetailState {
  final ArtistDetail? detail;
  final bool isLoading;
  final String? error;

  ArtistDetailState({
    this.detail,
    this.isLoading = false,
    this.error,
  });

  ArtistDetailState copyWith({
    ArtistDetail? detail,
    bool? isLoading,
    String? error,
  }) {
    return ArtistDetailState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ArtistDetailViewModel extends FamilyNotifier<ArtistDetailState, int> {
  late final ArtistRepository _artistRepo;

  @override
  ArtistDetailState build(int artistId) {
    _artistRepo = ref.read(artistRepoProvider);
    // 초기 데이터 로드
    Future.microtask(() => fetchArtistDetail(artistId));
    return ArtistDetailState(isLoading: true);
  }

  /// 아티스트 상세 가져오기
  Future<void> fetchArtistDetail(int artistId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final detail = await _artistRepo.getArtistDetail(artistId);
      if (detail != null) {
        state = state.copyWith(detail: detail, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: '아티스트를 찾을 수 없습니다',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '아티스트 정보를 불러올 수 없습니다',
      );
    }
  }

  /// 팔로우 토글 (낙관적 UI 업데이트)
  Future<void> toggleFollow() async {
    final detail = state.detail;
    if (detail == null) return;

    final artist = detail.artist;
    final wasFollowing = artist.isFollowing;

    // 낙관적 UI 업데이트
    final updatedArtist = artist.copyWith(
      isFollowing: !wasFollowing,
      followerCount: wasFollowing
          ? artist.followerCount - 1
          : artist.followerCount + 1,
    );
    state = state.copyWith(
      detail: detail.copyWith(artist: updatedArtist),
    );

    // API 호출
    try {
      final success = wasFollowing
          ? await _artistRepo.unfollow(artist.id)
          : await _artistRepo.follow(artist.id);

      if (!success) {
        // 실패 시 롤백
        state = state.copyWith(detail: detail);
      }
    } catch (e) {
      // 에러 시 롤백
      state = state.copyWith(detail: detail);
    }
  }

  /// 새로고침
  Future<void> refresh(int artistId) async {
    await fetchArtistDetail(artistId);
  }
}

final artistDetailProvider =
    NotifierProvider.family<ArtistDetailViewModel, ArtistDetailState, int>(
  () => ArtistDetailViewModel(),
);
