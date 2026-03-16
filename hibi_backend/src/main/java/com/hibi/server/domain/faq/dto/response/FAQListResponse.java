package com.hibi.server.domain.faq.dto.response;

import lombok.Builder;

import java.util.List;

@Builder
public record FAQListResponse(
        List<FAQResponse> faqs,
        int totalCount
) {
    public static FAQListResponse of(List<FAQResponse> faqs) {
        return FAQListResponse.builder()
                .faqs(faqs)
                .totalCount(faqs.size())
                .build();
    }

    public static FAQListResponse empty() {
        return FAQListResponse.builder()
                .faqs(List.of())
                .totalCount(0)
                .build();
    }
}
