package com.hibi.server.domain.comment.repository;

import com.hibi.server.domain.comment.entity.Comment;
import com.hibi.server.domain.report.entity.ReportTargetType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 댓글 Repository
 */
@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {

    /**
     * 게시글의 최상위 댓글 목록 조회 (대댓글 제외, 작성일 오름차순)
     * 작성자/대댓글/대댓글 작성자를 fetch join으로 함께 로딩해 N+1을 방지한다.
     */
    @Query("SELECT c FROM Comment c " +
           "JOIN FETCH c.member " +
           "LEFT JOIN FETCH c.replies r " +
           "LEFT JOIN FETCH r.member " +
           "WHERE c.feedPost.id = :feedPostId AND c.parent IS NULL " +
           "ORDER BY c.createdAt ASC, r.createdAt ASC")
    List<Comment> findTopLevelCommentsByFeedPostId(@Param("feedPostId") Long feedPostId);

    /**
     * 게시글의 전체 댓글 수 조회 (삭제된 댓글 제외)
     */
    @Query("SELECT COUNT(c) FROM Comment c WHERE c.feedPost.id = :feedPostId AND c.isDeleted = false")
    int countByFeedPostId(@Param("feedPostId") Long feedPostId);

    /**
     * 특정 댓글의 대댓글 목록 조회
     */
    @Query("SELECT c FROM Comment c WHERE c.parent.id = :parentId ORDER BY c.createdAt ASC")
    List<Comment> findRepliesByParentId(@Param("parentId") Long parentId);

    /**
     * 특정 댓글의 대댓글 수 조회 (삭제된 댓글 제외)
     */
    @Query("SELECT COUNT(c) FROM Comment c WHERE c.parent.id = :parentId AND c.isDeleted = false")
    int countRepliesByParentId(@Param("parentId") Long parentId);

    /**
     * 사용자가 작성한 댓글 목록 조회
     */
    List<Comment> findByMemberIdOrderByCreatedAtDesc(Long memberId);

    /**
     * 게시글 삭제 시 관련 댓글 모두 삭제
     */
    void deleteByFeedPostId(Long feedPostId);

    /**
     * 특정 회원이 작성한 댓글 수 조회 (F12)
     */
    long countByMemberId(Long memberId);

    /**
     * 게시글의 추천 Top3 댓글 조회 (F16: AC-F6-6)
     * 좋아요 수 내림차순, 동점 시 최신순. 삭제/필터링된 댓글 제외.
     */
    @Query("SELECT c FROM Comment c WHERE c.feedPost.id = :feedPostId " +
           "AND c.isDeleted = false AND c.isFiltered = false AND c.likeCount > 0 " +
           "ORDER BY c.likeCount DESC, c.createdAt DESC")
    List<Comment> findTopCommentsByFeedPostId(@Param("feedPostId") Long feedPostId);

    /**
     * 신고된 댓글 페이지 조회 (관리자용 - DB 레벨 필터링)
     */
    @Query("SELECT c FROM Comment c WHERE c.id IN " +
           "(SELECT r.targetId FROM Report r WHERE r.targetType = :targetType)")
    Page<Comment> findReportedComments(@Param("targetType") ReportTargetType targetType, Pageable pageable);
}
