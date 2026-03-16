package com.hibi.server.domain.admin.dto.response;

import com.hibi.server.domain.question.entity.Question;
import lombok.Builder;

import java.time.LocalDateTime;

/**
 * 관리자용 문의 응답 DTO (F12)
 */
@Builder
public record AdminQuestionResponse(
        Long id,
        Long memberId,
        String memberNickname,
        String memberEmail,
        String type,
        String title,
        String content,
        String status,
        String answer,
        LocalDateTime answeredAt,
        String questionNumber,
        LocalDateTime createdAt
) {
    public static AdminQuestionResponse from(Question question) {
        return AdminQuestionResponse.builder()
                .id(question.getId())
                .memberId(question.getMember().getId())
                .memberNickname(question.getMember().getNickname())
                .memberEmail(question.getMember().getEmail())
                .type(question.getType().name())
                .title(question.getTitle())
                .content(question.getContent())
                .status(question.getStatus().name())
                .answer(question.getAnswer())
                .answeredAt(question.getAnsweredAt())
                .questionNumber(question.getQuestionNumber())
                .createdAt(question.getCreatedAt())
                .build();
    }
}
