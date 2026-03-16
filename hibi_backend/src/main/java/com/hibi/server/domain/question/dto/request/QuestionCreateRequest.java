package com.hibi.server.domain.question.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * 문의 생성 요청 DTO (F10)
 */
public record QuestionCreateRequest(
        @NotNull(message = "문의 유형을 선택해주세요")
        String type,

        @NotBlank(message = "제목을 입력해주세요")
        @Size(max = 100, message = "제목은 100자 이내로 입력해주세요")
        String title,

        @NotBlank(message = "내용을 입력해주세요")
        @Size(min = 10, max = 1000, message = "내용은 10자 이상 1000자 이내로 입력해주세요")
        String content
) {
}
