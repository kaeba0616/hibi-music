package com.hibi.server.domain.songlike.service;

import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.song.entity.Song;
import com.hibi.server.domain.song.repository.SongRepository;
import com.hibi.server.domain.songlike.entity.SongLike;
import com.hibi.server.domain.songlike.repository.SongLikeRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SongLikeService {

    private final SongLikeRepository songLikeRepository;
    private final SongRepository songRepository;
    private final MemberRepository memberRepository;

    /**
     * 좋아요 토글 (좋아요 추가/삭제)
     * @return true: 좋아요 추가됨, false: 좋아요 삭제됨
     */
    @Transactional
    public boolean toggleLike(Long memberId, Long songId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        return songLikeRepository.findByMemberIdAndSongId(memberId, songId)
                .map(existingLike -> {
                    // 이미 좋아요가 있으면 삭제
                    songLikeRepository.delete(existingLike);
                    return false;
                })
                .orElseGet(() -> {
                    // 좋아요가 없으면 추가
                    SongLike newLike = SongLike.of(member, song);
                    songLikeRepository.save(newLike);
                    return true;
                });
    }

    /**
     * 특정 노래의 좋아요 여부 확인
     */
    public boolean isLiked(Long memberId, Long songId) {
        return songLikeRepository.existsByMemberIdAndSongId(memberId, songId);
    }

    /**
     * 특정 노래의 좋아요 개수
     */
    public long getLikeCount(Long songId) {
        return songLikeRepository.countBySongId(songId);
    }

    /**
     * 특정 회원이 좋아요한 전체 노래 ID 목록 (F15)
     */
    public List<Long> getLikedSongIds(Long memberId) {
        return songLikeRepository.findByMemberId(memberId).stream()
                .map(sl -> sl.getSong().getId())
                .toList();
    }

    /**
     * 특정 회원이 좋아요한 노래 ID 목록 (주어진 노래 목록에 대해)
     */
    public List<Long> getLikedSongIds(Long memberId, List<Long> songIds) {
        if (songIds == null || songIds.isEmpty()) {
            return List.of();
        }
        return songLikeRepository.findLikedSongIdsByMemberIdAndSongIds(memberId, songIds);
    }
}
