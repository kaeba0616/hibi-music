package com.hibi.server.domain.report.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 신고 여부 확인 응답 DTO (F11)
 */
@Schema(description = "신고 여부 확인 응답")
public record ReportCheckResponse(

        @Schema(description = "이미 신고했는지 여부", example = "true")
        boolean alreadyReported
) {

    public static ReportCheckResponse of(boolean alreadyReported) {
        return new ReportCheckResponse(alreadyReported);
    }
}
