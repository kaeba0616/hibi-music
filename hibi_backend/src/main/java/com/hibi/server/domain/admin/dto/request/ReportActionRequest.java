package com.hibi.server.domain.admin.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * 신고 처리 요청 DTO (F12)
 */
public record ReportActionRequest(
        @NotNull(message = "신고 ID는 필수입니다")
        Long reportId,

        @NotBlank(message = "처리 액션은 필수입니다")
        String action, // DISMISS, WARN, DELETE_CONTENT, SUSPEND, BAN

        String note, // 관리자 메모

        Integer suspensionDays // 정지 기간 (SUSPEND 시)
) {
    public boolean isDismiss() {
        return "DISMISS".equalsIgnoreCase(action);
    }

    public boolean isWarn() {
        return "WARN".equalsIgnoreCase(action);
    }

    public boolean isDeleteContent() {
        return "DELETE_CONTENT".equalsIgnoreCase(action);
    }

    public boolean isSuspend() {
        return "SUSPEND".equalsIgnoreCase(action);
    }

    public boolean isBan() {
        return "BAN".equalsIgnoreCase(action);
    }
}
