package com.hibi.server.domain.comment.dto.response;

import lombok.Builder;

import java.util.List;

/**
 * 댓글 목록 응답 DTO
 * Flutter의 CommentListResponse 모델과 매핑
 */
@Builder
public record CommentListResponse(
        List<CommentResponse> comments,
        Integer totalCount,
        Boolean hasMore
) {
    public static CommentListResponse of(List<CommentResponse> comments, int totalCount) {
        return CommentListResponse.builder()
                .comments(comments)
                .totalCount(totalCount)
                .hasMore(false)
                .build();
    }
}
