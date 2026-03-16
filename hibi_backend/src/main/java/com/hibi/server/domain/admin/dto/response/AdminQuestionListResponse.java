package com.hibi.server.domain.admin.dto.response;

import lombok.Builder;

import java.util.List;

/**
 * 관리자용 문의 목록 응답 DTO (F12)
 */
@Builder
public record AdminQuestionListResponse(
        List<AdminQuestionResponse> questions,
        int totalCount,
        int page,
        int pageSize
) {
    public static AdminQuestionListResponse of(
            List<AdminQuestionResponse> questions,
            long totalCount,
            int page,
            int pageSize
    ) {
        return AdminQuestionListResponse.builder()
                .questions(questions)
                .totalCount((int) totalCount)
                .page(page)
                .pageSize(pageSize)
                .build();
    }
}
