package com.hibi.server.domain.comment.repository;

import com.hibi.server.domain.comment.entity.CommentLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * 댓글 좋아요 Repository
 */
@Repository
public interface CommentLikeRepository extends JpaRepository<CommentLike, Long> {

    /**
     * 특정 사용자가 특정 댓글에 좋아요했는지 확인
     */
    Optional<CommentLike> findByMemberIdAndCommentId(Long memberId, Long commentId);

    /**
     * 특정 사용자가 특정 댓글에 좋아요했는지 여부
     */
    boolean existsByMemberIdAndCommentId(Long memberId, Long commentId);

    /**
     * 특정 사용자가 좋아요한 댓글 ID 목록 조회 (특정 댓글들 중에서)
     */
    @Query("SELECT cl.comment.id FROM CommentLike cl WHERE cl.member.id = :memberId AND cl.comment.id IN :commentIds")
    List<Long> findLikedCommentIdsByMemberIdAndCommentIds(
            @Param("memberId") Long memberId,
            @Param("commentIds") List<Long> commentIds
    );

    /**
     * 댓글 삭제 시 관련 좋아요 모두 삭제
     */
    void deleteByCommentId(Long commentId);

    /**
     * 여러 댓글의 좋아요 한번에 삭제
     */
    void deleteByCommentIdIn(List<Long> commentIds);
}
