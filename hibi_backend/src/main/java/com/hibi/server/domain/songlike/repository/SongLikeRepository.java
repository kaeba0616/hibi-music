package com.hibi.server.domain.songlike.repository;

import com.hibi.server.domain.songlike.entity.SongLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SongLikeRepository extends JpaRepository<SongLike, Long> {

    /**
     * 특정 회원이 특정 노래를 좋아요 했는지 확인
     */
    Optional<SongLike> findByMemberIdAndSongId(Long memberId, Long songId);

    /**
     * 특정 회원이 특정 노래를 좋아요 했는지 여부
     */
    boolean existsByMemberIdAndSongId(Long memberId, Long songId);

    /**
     * 특정 회원의 좋아요 목록
     */
    List<SongLike> findByMemberId(Long memberId);

    /**
     * 특정 노래의 좋아요 목록
     */
    List<SongLike> findBySongId(Long songId);

    /**
     * 특정 노래의 좋아요 개수
     */
    long countBySongId(Long songId);

    /**
     * 특정 회원이 특정 노래에 대한 좋아요 삭제
     */
    void deleteByMemberIdAndSongId(Long memberId, Long songId);

    /**
     * 특정 회원이 좋아요한 노래 ID 목록 (특정 노래 목록에 대해)
     */
    @Query("SELECT sl.song.id FROM SongLike sl WHERE sl.member.id = :memberId AND sl.song.id IN :songIds")
    List<Long> findLikedSongIdsByMemberIdAndSongIds(
            @Param("memberId") Long memberId,
            @Param("songIds") List<Long> songIds
    );
}
