package com.hibi.server.domain.admin.dto.response;

import com.hibi.server.domain.report.entity.Report;
import lombok.Builder;

import java.time.LocalDateTime;

/**
 * 관리자용 신고 응답 DTO (F12)
 */
@Builder
public record AdminReportResponse(
        Long id,
        Long reporterId,
        String reporterNickname,
        String targetType,
        Long targetId,
        String reason,
        String description,
        String status,
        LocalDateTime createdAt,
        AdminReportTargetContent targetContent
) {
    public static AdminReportResponse from(Report report) {
        return AdminReportResponse.builder()
                .id(report.getId())
                .reporterId(report.getReporter().getId())
                .reporterNickname(report.getReporter().getNickname())
                .targetType(report.getTargetType().name())
                .targetId(report.getTargetId())
                .reason(report.getReason().name())
                .description(report.getDescription())
                .status(report.getStatus().name())
                .createdAt(report.getCreatedAt())
                .build();
    }

    public static AdminReportResponse from(Report report, AdminReportTargetContent targetContent) {
        return AdminReportResponse.builder()
                .id(report.getId())
                .reporterId(report.getReporter().getId())
                .reporterNickname(report.getReporter().getNickname())
                .targetType(report.getTargetType().name())
                .targetId(report.getTargetId())
                .reason(report.getReason().name())
                .description(report.getDescription())
                .status(report.getStatus().name())
                .createdAt(report.getCreatedAt())
                .targetContent(targetContent)
                .build();
    }
}
