package com.hibi.server.domain.report.dto.response;

import com.hibi.server.domain.report.entity.Report;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

/**
 * 신고 응답 DTO (F11)
 */
@Schema(description = "신고 응답")
public record ReportResponse(

        @Schema(description = "신고 ID", example = "1")
        Long id,

        @Schema(description = "신고자 ID", example = "10")
        Long reporterId,

        @Schema(description = "신고 대상 유형", example = "POST")
        String targetType,

        @Schema(description = "신고 대상 ID", example = "42")
        Long targetId,

        @Schema(description = "신고 사유", example = "SPAM")
        String reason,

        @Schema(description = "신고 상세 내용", example = "부적절한 내용입니다")
        String description,

        @Schema(description = "신고 상태", example = "PENDING")
        String status,

        @Schema(description = "신고 일시", example = "2024-01-15T10:30:00")
        LocalDateTime createdAt
) {

    /**
     * Entity -> Response 변환
     */
    public static ReportResponse from(Report report) {
        return new ReportResponse(
                report.getId(),
                report.getReporter().getId(),
                report.getTargetType().name(),
                report.getTargetId(),
                report.getReason().name(),
                report.getDescription(),
                report.getStatus().name(),
                report.getCreatedAt()
        );
    }
}
