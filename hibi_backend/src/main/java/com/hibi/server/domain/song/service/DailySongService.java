package com.hibi.server.domain.song.service;

import com.hibi.server.domain.song.dto.response.DailySongResponse;
import com.hibi.server.domain.song.dto.response.RelatedSongResponse;
import com.hibi.server.domain.song.entity.RelatedSong;
import com.hibi.server.domain.song.entity.Song;
import com.hibi.server.domain.song.repository.RelatedSongRepository;
import com.hibi.server.domain.song.repository.SongRepository;
import com.hibi.server.domain.songlike.service.SongLikeService;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DailySongService {

    private final SongRepository songRepository;
    private final RelatedSongRepository relatedSongRepository;
    private final SongLikeService songLikeService;

    /**
     * 오늘의 노래 조회
     */
    public Optional<DailySongResponse> getTodaySong(Long memberId) {
        LocalDate today = LocalDate.now();
        return songRepository.findByRecommendDate(today)
                .map(song -> toDailySongResponse(song, memberId));
    }

    /**
     * 날짜별 노래 조회
     */
    public Optional<DailySongResponse> getSongByDate(LocalDate date, Long memberId) {
        return songRepository.findByRecommendDate(date)
                .map(song -> toDailySongResponse(song, memberId));
    }

    /**
     * ID로 노래 상세 조회 (연관곡 포함)
     */
    public DailySongResponse getSongById(Long songId, Long memberId) {
        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        List<RelatedSongResponse> relatedSongs = getRelatedSongs(songId);
        return toDailySongResponse(song, memberId, relatedSongs);
    }

    /**
     * 연관곡 목록 조회 (F15)
     */
    public List<RelatedSongResponse> getRelatedSongs(Long songId) {
        List<RelatedSong> relatedSongs = relatedSongRepository.findBySongIdWithDetails(songId);
        return relatedSongs.stream()
                .map(RelatedSongResponse::from)
                .toList();
    }

    /**
     * 좋아요 곡 목록 조회 (F15)
     */
    public List<DailySongResponse> getLikedSongs(Long memberId) {
        List<Long> likedSongIds = songLikeService.getLikedSongIds(memberId);
        if (likedSongIds.isEmpty()) return List.of();

        return likedSongIds.stream()
                .map(songRepository::findById)
                .filter(Optional::isPresent)
                .map(Optional::get)
                .map(song -> DailySongResponse.from(song, true, songLikeService.getLikeCount(song.getId())))
                .toList();
    }

    /**
     * 월별 노래 목록 조회
     */
    public List<DailySongResponse> getSongsByMonth(int year, int month, Long memberId) {
        List<Song> songs = songRepository.findByRecommendDateYearAndMonth(year, month);

        if (songs.isEmpty()) {
            return List.of();
        }

        // 한 번에 좋아요 정보 조회 (N+1 방지)
        List<Long> songIds = songs.stream().map(Song::getId).toList();
        Set<Long> likedSongIds = memberId != null
                ? Set.copyOf(songLikeService.getLikedSongIds(memberId, songIds))
                : Set.of();

        return songs.stream()
                .map(song -> {
                    boolean isLiked = likedSongIds.contains(song.getId());
                    long likeCount = songLikeService.getLikeCount(song.getId());
                    return DailySongResponse.from(song, isLiked, likeCount);
                })
                .collect(Collectors.toList());
    }

    /**
     * 좋아요 토글
     */
    @Transactional
    public boolean toggleLike(Long memberId, Long songId) {
        // 노래 존재 확인
        if (!songRepository.existsById(songId)) {
            throw new CustomException(ErrorCode.ENTITY_NOT_FOUND);
        }

        return songLikeService.toggleLike(memberId, songId);
    }

    /**
     * Song을 DailySongResponse로 변환 (좋아요 정보 포함)
     */
    private DailySongResponse toDailySongResponse(Song song, Long memberId) {
        boolean isLiked = memberId != null && songLikeService.isLiked(memberId, song.getId());
        long likeCount = songLikeService.getLikeCount(song.getId());
        return DailySongResponse.from(song, isLiked, likeCount);
    }

    private DailySongResponse toDailySongResponse(Song song, Long memberId, List<RelatedSongResponse> relatedSongs) {
        boolean isLiked = memberId != null && songLikeService.isLiked(memberId, song.getId());
        long likeCount = songLikeService.getLikeCount(song.getId());
        return DailySongResponse.from(song, isLiked, likeCount, relatedSongs);
    }
}
