package com.hibi.server.domain.admin.dto.response;

import lombok.Builder;

/**
 * 관리자 대시보드 통계 응답 DTO (F12)
 */
@Builder
public record AdminStatsResponse(
        int totalMembers,
        int todayNewMembers,
        int pendingReports,
        int todayNewReports,
        int unansweredQuestions,
        int totalFaqs
) {
    public static AdminStatsResponse of(
            long totalMembers,
            long todayNewMembers,
            long pendingReports,
            long todayNewReports,
            long unansweredQuestions,
            long totalFaqs
    ) {
        return AdminStatsResponse.builder()
                .totalMembers((int) totalMembers)
                .todayNewMembers((int) todayNewMembers)
                .pendingReports((int) pendingReports)
                .todayNewReports((int) todayNewReports)
                .unansweredQuestions((int) unansweredQuestions)
                .totalFaqs((int) totalFaqs)
                .build();
    }
}
