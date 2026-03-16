package com.hibi.server.domain.comment.dto.response;

import com.hibi.server.domain.comment.entity.Comment;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 댓글 응답 DTO
 * Flutter의 Comment 모델과 매핑
 */
@Builder
public record CommentResponse(
        Long id,
        Long postId,
        CommentAuthorResponse author,
        String content,
        Long parentId,
        String parentAuthorNickname,
        Integer likeCount,
        Boolean isLiked,
        Boolean isDeleted,
        LocalDateTime createdAt,
        LocalDateTime updatedAt,
        List<CommentResponse> replies
) {
    /**
     * 일반 댓글 응답 생성 (대댓글 포함)
     */
    public static CommentResponse from(Comment comment, boolean isLiked, List<CommentResponse> replies) {
        if (comment.getIsDeleted()) {
            return CommentResponse.builder()
                    .id(comment.getId())
                    .postId(comment.getFeedPost().getId())
                    .author(CommentAuthorResponse.deleted())
                    .content("")
                    .parentId(null)
                    .parentAuthorNickname(null)
                    .likeCount(0)
                    .isLiked(false)
                    .isDeleted(true)
                    .createdAt(comment.getCreatedAt())
                    .updatedAt(comment.getUpdatedAt())
                    .replies(replies != null ? replies : List.of())
                    .build();
        }

        return CommentResponse.builder()
                .id(comment.getId())
                .postId(comment.getFeedPost().getId())
                .author(CommentAuthorResponse.from(comment.getMember()))
                .content(comment.getContent())
                .parentId(comment.getParent() != null ? comment.getParent().getId() : null)
                .parentAuthorNickname(comment.getParentAuthorNickname())
                .likeCount(comment.getLikeCount())
                .isLiked(isLiked)
                .isDeleted(false)
                .createdAt(comment.getCreatedAt())
                .updatedAt(comment.getUpdatedAt())
                .replies(replies != null ? replies : List.of())
                .build();
    }

    /**
     * 대댓글 응답 생성 (replies 없음)
     */
    public static CommentResponse fromReply(Comment comment, boolean isLiked) {
        return from(comment, isLiked, List.of());
    }
}
