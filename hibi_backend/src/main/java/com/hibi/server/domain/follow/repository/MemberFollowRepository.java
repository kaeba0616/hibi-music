package com.hibi.server.domain.follow.repository;

import com.hibi.server.domain.follow.entity.MemberFollow;
import com.hibi.server.domain.member.entity.Member;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MemberFollowRepository extends JpaRepository<MemberFollow, Long> {

    /**
     * 팔로우 관계 존재 여부 확인
     */
    boolean existsByFollowerIdAndFollowingId(Long followerId, Long followingId);

    /**
     * 팔로우 관계 조회
     */
    Optional<MemberFollow> findByFollowerIdAndFollowingId(Long followerId, Long followingId);

    /**
     * 특정 사용자의 팔로워 목록 (follower → following)
     * following_id가 주어진 사용자인 경우의 follower들
     */
    @Query("SELECT mf FROM MemberFollow mf " +
           "JOIN FETCH mf.follower " +
           "WHERE mf.following.id = :userId " +
           "AND mf.follower.deletedAt IS NULL " +
           "ORDER BY mf.createdAt DESC")
    Page<MemberFollow> findFollowersByUserId(@Param("userId") Long userId, Pageable pageable);

    /**
     * 특정 사용자의 팔로잉 목록 (follower → following)
     * follower_id가 주어진 사용자인 경우의 following들
     */
    @Query("SELECT mf FROM MemberFollow mf " +
           "JOIN FETCH mf.following " +
           "WHERE mf.follower.id = :userId " +
           "AND mf.following.deletedAt IS NULL " +
           "ORDER BY mf.createdAt DESC")
    Page<MemberFollow> findFollowingsByUserId(@Param("userId") Long userId, Pageable pageable);

    /**
     * 특정 사용자의 팔로워 수
     */
    @Query("SELECT COUNT(mf) FROM MemberFollow mf " +
           "WHERE mf.following.id = :userId " +
           "AND mf.follower.deletedAt IS NULL")
    long countFollowersByUserId(@Param("userId") Long userId);

    /**
     * 특정 사용자의 팔로잉 수
     */
    @Query("SELECT COUNT(mf) FROM MemberFollow mf " +
           "WHERE mf.follower.id = :userId " +
           "AND mf.following.deletedAt IS NULL")
    long countFollowingsByUserId(@Param("userId") Long userId);

    /**
     * 현재 사용자가 팔로우하는 사용자 ID 목록
     */
    @Query("SELECT mf.following.id FROM MemberFollow mf " +
           "WHERE mf.follower.id = :userId " +
           "AND mf.following.deletedAt IS NULL")
    List<Long> findFollowingIdsByUserId(@Param("userId") Long userId);

    /**
     * 팔로우 관계 삭제
     */
    void deleteByFollowerIdAndFollowingId(Long followerId, Long followingId);

    /**
     * 특정 사용자들에 대한 팔로우 여부 일괄 확인
     */
    @Query("SELECT mf.following.id FROM MemberFollow mf " +
           "WHERE mf.follower.id = :currentUserId " +
           "AND mf.following.id IN :targetUserIds")
    List<Long> findFollowingIdsAmong(
            @Param("currentUserId") Long currentUserId,
            @Param("targetUserIds") List<Long> targetUserIds
    );

    // ========== F12 관리자 기능용 쿼리 메서드 ==========

    /**
     * 특정 사용자의 팔로워 수 (간단 버전)
     */
    long countByFollowingId(Long followingId);

    /**
     * 특정 사용자의 팔로잉 수 (간단 버전)
     */
    long countByFollowerId(Long followerId);
}
