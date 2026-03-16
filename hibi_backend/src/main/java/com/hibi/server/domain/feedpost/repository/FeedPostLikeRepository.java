package com.hibi.server.domain.feedpost.repository;

import com.hibi.server.domain.feedpost.entity.FeedPostLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface FeedPostLikeRepository extends JpaRepository<FeedPostLike, Long> {

    /**
     * 특정 회원이 특정 게시글에 좋아요했는지 확인
     */
    boolean existsByMemberIdAndFeedPostId(Long memberId, Long feedPostId);

    /**
     * 특정 회원의 특정 게시글 좋아요 조회
     */
    Optional<FeedPostLike> findByMemberIdAndFeedPostId(Long memberId, Long feedPostId);

    /**
     * 특정 회원의 특정 게시글 좋아요 삭제
     */
    @Modifying
    @Query("DELETE FROM FeedPostLike l WHERE l.member.id = :memberId AND l.feedPost.id = :feedPostId")
    void deleteByMemberIdAndFeedPostId(@Param("memberId") Long memberId, @Param("feedPostId") Long feedPostId);

    /**
     * 게시글의 좋아요 개수
     */
    long countByFeedPostId(Long feedPostId);
}
