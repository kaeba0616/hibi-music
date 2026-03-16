package com.hibi.server.domain.faq.dto.response;

import com.hibi.server.domain.faq.entity.FAQ;
import com.hibi.server.domain.faq.entity.FAQCategory;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record FAQResponse(
        Long id,
        String question,
        String answer,
        String category,
        String categoryLabel,
        Integer order,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
    public static FAQResponse from(FAQ faq) {
        return FAQResponse.builder()
                .id(faq.getId())
                .question(faq.getQuestion())
                .answer(faq.getAnswer())
                .category(faq.getCategory().name().toLowerCase())
                .categoryLabel(faq.getCategory().getLabel())
                .order(faq.getDisplayOrder())
                .createdAt(faq.getCreatedAt())
                .updatedAt(faq.getUpdatedAt())
                .build();
    }
}
