package com.hibi.server.domain.faq.controller;

import com.hibi.server.domain.faq.dto.response.FAQListResponse;
import com.hibi.server.domain.faq.dto.response.FAQResponse;
import com.hibi.server.domain.faq.service.FAQService;
import com.hibi.server.global.response.SuccessResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/faqs")
@RequiredArgsConstructor
@Tag(name = "FAQ", description = "자주 묻는 질문 API")
public class FAQController {

    private final FAQService faqService;

    @GetMapping
    @Operation(
            summary = "FAQ 목록 조회",
            description = "FAQ 목록을 조회합니다. 카테고리 필터와 키워드 검색을 지원합니다."
    )
    public ResponseEntity<SuccessResponse<FAQListResponse>> getFAQs(
            @Parameter(description = "카테고리 필터 (all, account, service, community, other)")
            @RequestParam(value = "category", required = false) String category,

            @Parameter(description = "검색 키워드 (질문/답변에서 검색)")
            @RequestParam(value = "keyword", required = false) String keyword
    ) {
        FAQListResponse response = faqService.getFAQs(category, keyword);

        String message = response.totalCount() > 0
                ? "FAQ 조회 성공"
                : "등록된 FAQ가 없습니다";

        return ResponseEntity.ok(SuccessResponse.success(message, response));
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "FAQ 상세 조회",
            description = "특정 FAQ의 상세 정보를 조회합니다."
    )
    public ResponseEntity<SuccessResponse<FAQResponse>> getFAQById(
            @Parameter(description = "FAQ ID", required = true)
            @PathVariable Long id
    ) {
        FAQResponse response = faqService.getFAQById(id);
        return ResponseEntity.ok(SuccessResponse.success("FAQ 조회 성공", response));
    }
}
