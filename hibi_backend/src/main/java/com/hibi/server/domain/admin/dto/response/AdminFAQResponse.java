package com.hibi.server.domain.admin.dto.response;

import com.hibi.server.domain.faq.entity.FAQ;
import lombok.Builder;

import java.time.LocalDateTime;

/**
 * 관리자용 FAQ 응답 DTO (F12)
 */
@Builder
public record AdminFAQResponse(
        Long id,
        String category,
        String question,
        String answer,
        int displayOrder,
        boolean isPublished,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
    public static AdminFAQResponse from(FAQ faq) {
        return AdminFAQResponse.builder()
                .id(faq.getId())
                .category(faq.getCategory().name())
                .question(faq.getQuestion())
                .answer(faq.getAnswer())
                .displayOrder(faq.getDisplayOrder())
                .isPublished(faq.getIsPublished())
                .createdAt(faq.getCreatedAt())
                .updatedAt(faq.getUpdatedAt())
                .build();
    }
}
