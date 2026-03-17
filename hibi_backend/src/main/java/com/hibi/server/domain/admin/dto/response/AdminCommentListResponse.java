package com.hibi.server.domain.admin.dto.response;

import java.util.List;

/**
 * F18: 관리자 댓글 목록 응답 DTO
 */
public record AdminCommentListResponse(
        List<AdminCommentResponse> comments,
        long totalCount,
        int page,
        int pageSize
) {
    public static AdminCommentListResponse of(
            List<AdminCommentResponse> comments,
            long totalCount,
            int page,
            int pageSize
    ) {
        return new AdminCommentListResponse(comments, totalCount, page, pageSize);
    }
}
