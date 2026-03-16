package com.hibi.server.domain.feedpost.dto.response;

import lombok.Builder;
import org.springframework.data.domain.Page;

import java.util.List;

/**
 * 피드 게시글 목록 응답 DTO (페이징 포함)
 */
@Builder
public record FeedPostListResponse(
        List<FeedPostResponse> content,
        int page,
        int size,
        long totalElements,
        int totalPages,
        boolean hasNext,
        boolean hasPrevious
) {
    public static FeedPostListResponse from(Page<FeedPostResponse> page) {
        return FeedPostListResponse.builder()
                .content(page.getContent())
                .page(page.getNumber())
                .size(page.getSize())
                .totalElements(page.getTotalElements())
                .totalPages(page.getTotalPages())
                .hasNext(page.hasNext())
                .hasPrevious(page.hasPrevious())
                .build();
    }

    public static FeedPostListResponse empty() {
        return FeedPostListResponse.builder()
                .content(List.of())
                .page(0)
                .size(20)
                .totalElements(0)
                .totalPages(0)
                .hasNext(false)
                .hasPrevious(false)
                .build();
    }
}
