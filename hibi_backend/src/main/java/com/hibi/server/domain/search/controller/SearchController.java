package com.hibi.server.domain.search.controller;

import com.hibi.server.domain.search.dto.response.SearchResponse;
import com.hibi.server.domain.search.service.SearchService;
import com.hibi.server.global.response.SuccessResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/search")
@RequiredArgsConstructor
@Tag(name = "Search", description = "통합 검색 API")
public class SearchController {

    private final SearchService searchService;

    @GetMapping
    @Operation(
            summary = "통합 검색",
            description = "노래, 아티스트, 게시글, 사용자를 한 번에 검색합니다."
    )
    public ResponseEntity<SuccessResponse<SearchResponse>> search(
            @Parameter(description = "검색어 (필수)", required = true)
            @RequestParam("q") String keyword,

            @Parameter(description = "검색 카테고리 (all, songs, artists, posts, users)")
            @RequestParam(value = "category", defaultValue = "all") String category,

            @Parameter(description = "각 카테고리별 최대 결과 수 (기본: 10, 최대: 50)")
            @RequestParam(value = "limit", required = false) Integer limit
    ) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(SuccessResponse.success("검색어를 입력해주세요", SearchResponse.empty("")));
        }

        SearchResponse response = searchService.search(keyword, category, limit);

        String message = response.totalCount().songs() + response.totalCount().artists() +
                response.totalCount().posts() + response.totalCount().users() > 0
                ? "검색 성공"
                : "검색 결과가 없습니다";

        return ResponseEntity.ok(SuccessResponse.success(message, response));
    }
}
