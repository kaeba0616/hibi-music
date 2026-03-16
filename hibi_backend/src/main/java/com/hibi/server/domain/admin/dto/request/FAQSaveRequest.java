package com.hibi.server.domain.admin.dto.request;

import com.hibi.server.domain.faq.entity.FAQCategory;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * FAQ 생성/수정 요청 DTO (F12)
 */
public record FAQSaveRequest(
        Long id, // null이면 생성, 있으면 수정

        @NotNull(message = "카테고리는 필수입니다")
        String category,

        @NotBlank(message = "질문은 필수입니다")
        @Size(max = 500, message = "질문은 500자 이하여야 합니다")
        String question,

        @NotBlank(message = "답변은 필수입니다")
        @Size(max = 5000, message = "답변은 5000자 이하여야 합니다")
        String answer,

        @NotNull(message = "표시 순서는 필수입니다")
        Integer displayOrder,

        Boolean isPublished
) {
    public boolean isCreate() {
        return id == null;
    }

    public boolean isUpdate() {
        return id != null;
    }

    public FAQCategory getCategoryEnum() {
        try {
            return FAQCategory.valueOf(category);
        } catch (IllegalArgumentException e) {
            return FAQCategory.OTHER;
        }
    }

    public boolean getIsPublishedOrDefault() {
        return isPublished != null ? isPublished : true;
    }
}
