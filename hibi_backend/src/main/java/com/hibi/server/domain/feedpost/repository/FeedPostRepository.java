package com.hibi.server.domain.feedpost.repository;

import com.hibi.server.domain.feedpost.entity.FeedPost;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FeedPostRepository extends JpaRepository<FeedPost, Long> {

    /**
     * 피드 게시글 목록 조회 (최신순)
     * member와 taggedSong을 함께 조회하여 N+1 문제 방지
     */
    @EntityGraph(attributePaths = {"member", "taggedSong", "taggedSong.artist", "taggedSong.album"})
    @Query("SELECT fp FROM FeedPost fp ORDER BY fp.createdAt DESC")
    Page<FeedPost> findAllOrderByCreatedAtDesc(Pageable pageable);

    /**
     * 게시글 상세 조회 (member, taggedSong, images 함께 조회)
     */
    @EntityGraph(attributePaths = {"member", "taggedSong", "taggedSong.artist", "taggedSong.album", "images"})
    Optional<FeedPost> findWithDetailsById(Long id);

    /**
     * 특정 회원의 게시글 목록 조회
     */
    @EntityGraph(attributePaths = {"member", "taggedSong", "taggedSong.artist"})
    Page<FeedPost> findByMemberIdOrderByCreatedAtDesc(Long memberId, Pageable pageable);

    /**
     * 특정 노래가 태그된 게시글 목록 조회
     */
    @EntityGraph(attributePaths = {"member", "taggedSong", "taggedSong.artist"})
    Page<FeedPost> findByTaggedSongIdOrderByCreatedAtDesc(Long songId, Pageable pageable);

    /**
     * 팔로잉 피드 조회 (팔로우하는 사용자들의 게시글)
     */
    @EntityGraph(attributePaths = {"member", "taggedSong", "taggedSong.artist", "taggedSong.album"})
    @Query("SELECT fp FROM FeedPost fp WHERE fp.member.id IN :memberIds ORDER BY fp.createdAt DESC")
    Page<FeedPost> findByMemberIdInOrderByCreatedAtDesc(
            @Param("memberIds") List<Long> memberIds,
            Pageable pageable
    );

    /**
     * 특정 회원의 게시글 수
     */
    long countByMemberId(Long memberId);

    /**
     * 여러 회원의 게시글 수 일괄 조회 ([memberId, count] 행 반환, N+1 방지)
     */
    @Query("SELECT fp.member.id, COUNT(fp) FROM FeedPost fp WHERE fp.member.id IN :memberIds GROUP BY fp.member.id")
    List<Object[]> countGroupedByMemberIdIn(@Param("memberIds") List<Long> memberIds);

    /**
     * 게시글 검색 (내용으로 검색)
     */
    @EntityGraph(attributePaths = {"member"})
    @Query("SELECT fp FROM FeedPost fp WHERE LOWER(fp.content) LIKE LOWER(CONCAT('%', :keyword, '%')) ORDER BY fp.createdAt DESC")
    List<FeedPost> searchByKeyword(@Param("keyword") String keyword, Pageable pageable);
}
