package com.hibi.server.domain.faq.service;

import com.hibi.server.domain.faq.dto.response.FAQListResponse;
import com.hibi.server.domain.faq.dto.response.FAQResponse;
import com.hibi.server.domain.faq.entity.FAQ;
import com.hibi.server.domain.faq.entity.FAQCategory;
import com.hibi.server.domain.faq.repository.FAQRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FAQService {

    private final FAQRepository faqRepository;

    /**
     * FAQ 목록 조회 (필터 + 검색)
     */
    public FAQListResponse getFAQs(String category, String keyword) {
        List<FAQ> faqs;

        // 카테고리와 키워드 모두 있는 경우
        if (category != null && !category.isEmpty() && !category.equalsIgnoreCase("all") &&
            keyword != null && !keyword.isEmpty()) {
            FAQCategory faqCategory = FAQCategory.fromString(category);
            faqs = faqRepository.searchByCategoryAndKeyword(faqCategory, keyword);
        }
        // 카테고리만 있는 경우
        else if (category != null && !category.isEmpty() && !category.equalsIgnoreCase("all")) {
            FAQCategory faqCategory = FAQCategory.fromString(category);
            faqs = faqRepository.findByCategory(faqCategory);
        }
        // 키워드만 있는 경우
        else if (keyword != null && !keyword.isEmpty()) {
            faqs = faqRepository.searchByKeyword(keyword);
        }
        // 필터 없이 전체 조회
        else {
            faqs = faqRepository.findAllPublished();
        }

        List<FAQResponse> faqResponses = faqs.stream()
                .map(FAQResponse::from)
                .collect(Collectors.toList());

        return FAQListResponse.of(faqResponses);
    }

    /**
     * 단일 FAQ 조회
     */
    public FAQResponse getFAQById(Long id) {
        FAQ faq = faqRepository.findById(id)
                .filter(FAQ::getIsPublished)
                .orElseThrow(() -> new IllegalArgumentException("FAQ를 찾을 수 없습니다."));

        return FAQResponse.from(faq);
    }
}
