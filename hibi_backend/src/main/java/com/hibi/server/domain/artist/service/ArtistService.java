package com.hibi.server.domain.artist.service;

import com.hibi.server.domain.artist.dto.request.ArtistCreateRequest;
import com.hibi.server.domain.artist.dto.request.ArtistUpdateRequest;
import com.hibi.server.domain.artist.dto.response.*;
import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.artist.repository.ArtistRepository;
import com.hibi.server.domain.artistfollow.service.ArtistFollowService;
import com.hibi.server.domain.song.entity.Song;
import com.hibi.server.domain.song.repository.SongRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ArtistService {

    private final ArtistRepository artistRepository;
    private final SongRepository songRepository;
    private final ArtistFollowService artistFollowService;

    /**
     * 아티스트 생성 (관리자)
     */
    @Transactional
    public void create(ArtistCreateRequest request) {
        Artist artist = Artist.builder()
                .nameKor(request.nameKor())
                .nameEng(request.nameEng())
                .nameJp(request.nameJp())
                .profileUrl("default.png")
                .build();
        artistRepository.save(artist);
    }

    /**
     * 아티스트 단건 조회 (Entity)
     */
    public Artist getById(Long id) {
        return artistRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));
    }

    /**
     * 아티스트 수정 (관리자)
     */
    @Transactional
    public ArtistResponse update(Long id, ArtistUpdateRequest request) {
        Artist artist = artistRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        artist.update(request);
        return ArtistResponse.from(artist);
    }

    /**
     * 아티스트 삭제 (관리자)
     */
    @Transactional
    public void delete(Long id) {
        artistRepository.deleteById(id);
    }

    /**
     * 아티스트 전체 조회 (기존 호환성)
     */
    @Transactional(readOnly = true)
    public List<ArtistResponse> getAll() {
        return artistRepository.findAll().stream()
                .map(ArtistResponse::from)
                .toList();
    }

    /**
     * 아티스트 목록 조회 (AC-F3-1, AC-F3-4)
     * 페이지네이션, 검색, 팔로우 필터 지원
     */
    public ArtistPageResponse getArtistList(
            Long memberId,
            Boolean followingOnly,
            String search,
            Pageable pageable
    ) {
        Page<Artist> artistPage;

        // 팔로우 필터
        if (Boolean.TRUE.equals(followingOnly)) {
            List<Long> followedArtistIds = artistFollowService.getFollowedArtistIds(memberId);
            if (followedArtistIds.isEmpty()) {
                return ArtistPageResponse.of(
                        List.of(),
                        0,
                        0,
                        pageable.getPageNumber(),
                        pageable.getPageSize()
                );
            }

            if (search != null && !search.isBlank()) {
                artistPage = artistRepository.searchByNameInIds(search, followedArtistIds, pageable);
            } else {
                artistPage = artistRepository.findByIdIn(followedArtistIds, pageable);
            }
        } else {
            if (search != null && !search.isBlank()) {
                artistPage = artistRepository.searchByName(search, pageable);
            } else {
                artistPage = artistRepository.findAll(pageable);
            }
        }

        // 팔로우 상태 및 노래 수 조회
        List<Long> artistIds = artistPage.getContent().stream()
                .map(Artist::getId)
                .toList();

        Set<Long> followedIds = artistFollowService.getFollowedArtistIdsIn(memberId, artistIds);

        List<ArtistListResponse> content = artistPage.getContent().stream()
                .map(artist -> ArtistListResponse.of(
                        artist,
                        songRepository.countByArtistId(artist.getId()),
                        followedIds.contains(artist.getId())
                ))
                .toList();

        return ArtistPageResponse.of(
                content,
                artistPage.getTotalPages(),
                artistPage.getTotalElements(),
                artistPage.getNumber(),
                artistPage.getSize()
        );
    }

    /**
     * 아티스트 상세 조회 (AC-F3-2)
     */
    public ArtistDetailResponse getArtistDetail(Long artistId, Long memberId) {
        Artist artist = artistRepository.findById(artistId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        // 팔로워 수
        long followerCount = artistFollowService.getFollowerCount(artistId);

        // 노래 목록
        List<Song> songs = songRepository.findByArtistId(artistId);
        long songCount = songs.size();

        // 팔로우 상태
        boolean isFollowing = artistFollowService.isFollowing(memberId, artistId);

        // 노래 응답 변환
        List<ArtistSongResponse> songResponses = songs.stream()
                .map(ArtistSongResponse::from)
                .toList();

        return ArtistDetailResponse.of(
                artist,
                followerCount,
                songCount,
                isFollowing,
                songResponses
        );
    }
}
