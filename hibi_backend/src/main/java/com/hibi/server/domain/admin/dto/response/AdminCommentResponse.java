package com.hibi.server.domain.admin.dto.response;

import com.hibi.server.domain.comment.entity.Comment;

import java.time.LocalDateTime;

/**
 * F18: 관리자 댓글 응답 DTO
 */
public record AdminCommentResponse(
        Long id,
        Long feedPostId,
        String authorNickname,
        Long authorId,
        String content,
        int likeCount,
        int reportCount,
        boolean isFiltered,
        LocalDateTime createdAt
) {
    public static AdminCommentResponse from(Comment comment, int reportCount) {
        return new AdminCommentResponse(
                comment.getId(),
                comment.getFeedPost().getId(),
                comment.getMember().getNickname(),
                comment.getMember().getId(),
                comment.getContent(),
                comment.getLikeCount(),
                reportCount,
                comment.getIsFiltered(),
                comment.getCreatedAt()
        );
    }
}
