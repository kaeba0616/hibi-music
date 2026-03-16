package com.hibi.server.domain.admin.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * 회원 제재 요청 DTO (F12)
 */
public record MemberSanctionRequest(
        @NotNull(message = "회원 ID는 필수입니다")
        Long memberId,

        @NotBlank(message = "제재 유형은 필수입니다")
        String sanctionType, // SUSPEND, BAN

        Integer durationDays, // 정지 기간 (일), null이면 영구 정지

        String reason // 제재 사유
) {
    public boolean isSuspend() {
        return "SUSPEND".equalsIgnoreCase(sanctionType);
    }

    public boolean isBan() {
        return "BAN".equalsIgnoreCase(sanctionType);
    }
}
