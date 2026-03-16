package com.hibi.server.domain.admin.dto.response;

import lombok.Builder;

import java.util.List;

/**
 * 관리자용 신고 목록 응답 DTO (F12)
 */
@Builder
public record AdminReportListResponse(
        List<AdminReportResponse> reports,
        int totalCount,
        int page,
        int pageSize
) {
    public static AdminReportListResponse of(
            List<AdminReportResponse> reports,
            long totalCount,
            int page,
            int pageSize
    ) {
        return AdminReportListResponse.builder()
                .reports(reports)
                .totalCount((int) totalCount)
                .page(page)
                .pageSize(pageSize)
                .build();
    }
}
