package com.hibi.server.domain.admin.dto.response;

import lombok.Builder;

import java.util.List;

/**
 * 관리자용 FAQ 목록 응답 DTO (F12)
 */
@Builder
public record AdminFAQListResponse(
        List<AdminFAQResponse> faqs,
        int totalCount
) {
    public static AdminFAQListResponse of(List<AdminFAQResponse> faqs) {
        return AdminFAQListResponse.builder()
                .faqs(faqs)
                .totalCount(faqs.size())
                .build();
    }
}
