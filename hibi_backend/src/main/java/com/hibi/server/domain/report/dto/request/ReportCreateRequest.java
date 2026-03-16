package com.hibi.server.domain.report.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * 신고 생성 요청 DTO (F11)
 */
@Schema(description = "신고 생성 요청")
public record ReportCreateRequest(

        @Schema(description = "신고 대상 유형", example = "POST", allowableValues = {"POST", "COMMENT", "MEMBER"})
        @NotBlank(message = "신고 대상 유형은 필수입니다")
        String targetType,

        @Schema(description = "신고 대상 ID", example = "42")
        @NotNull(message = "신고 대상 ID는 필수입니다")
        Long targetId,

        @Schema(description = "신고 사유", example = "SPAM", allowableValues = {"SPAM", "ABUSE", "INAPPROPRIATE", "COPYRIGHT", "OTHER"})
        @NotBlank(message = "신고 사유는 필수입니다")
        String reason,

        @Schema(description = "신고 상세 내용 (기타 선택 시)", example = "부적절한 내용입니다")
        @Size(max = 300, message = "상세 내용은 300자 이하여야 합니다")
        String description
) {
}
