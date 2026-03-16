package com.hibi.server.domain.question.dto.response;

import lombok.Builder;

import java.util.List;

/**
 * 문의 목록 응답 DTO (F10)
 */
@Builder
public record QuestionListResponse(
        List<QuestionResponse> questions,
        int totalCount
) {
    public static QuestionListResponse of(List<QuestionResponse> questions) {
        return QuestionListResponse.builder()
                .questions(questions)
                .totalCount(questions.size())
                .build();
    }

    public static QuestionListResponse empty() {
        return QuestionListResponse.builder()
                .questions(List.of())
                .totalCount(0)
                .build();
    }
}
