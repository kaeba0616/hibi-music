package com.hibi.server.domain.admin.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * 문의 답변 요청 DTO (F12)
 */
public record QuestionAnswerRequest(
        @NotNull(message = "문의 ID는 필수입니다")
        Long questionId,

        @NotBlank(message = "답변 내용은 필수입니다")
        @Size(max = 2000, message = "답변은 2000자 이하여야 합니다")
        String answer
) {
}
