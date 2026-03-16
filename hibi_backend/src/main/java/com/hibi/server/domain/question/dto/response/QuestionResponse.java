package com.hibi.server.domain.question.dto.response;

import com.hibi.server.domain.question.entity.Question;
import lombok.Builder;

import java.time.LocalDateTime;

/**
 * 문의 응답 DTO (F10)
 */
@Builder
public record QuestionResponse(
        Long id,
        Long memberId,
        String type,
        String typeLabel,
        String title,
        String content,
        String status,
        String statusLabel,
        String answer,
        LocalDateTime answeredAt,
        String questionNumber,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
    public static QuestionResponse from(Question question) {
        return QuestionResponse.builder()
                .id(question.getId())
                .memberId(question.getMember().getId())
                .type(question.getType().name().toLowerCase())
                .typeLabel(question.getType().getLabel())
                .title(question.getTitle())
                .content(question.getContent())
                .status(question.getStatus().name().toLowerCase())
                .statusLabel(question.getStatus().getLabel())
                .answer(question.getAnswer())
                .answeredAt(question.getAnsweredAt())
                .questionNumber(question.getQuestionNumber())
                .createdAt(question.getCreatedAt())
                .updatedAt(question.getUpdatedAt())
                .build();
    }
}
