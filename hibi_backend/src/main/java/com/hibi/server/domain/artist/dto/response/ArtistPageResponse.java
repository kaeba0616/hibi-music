package com.hibi.server.domain.artist.dto.response;

import lombok.Builder;
import org.springframework.data.domain.Page;

import java.util.List;

/**
 * 아티스트 페이지 응답 DTO
 */
@Builder
public record ArtistPageResponse(
        List<ArtistListResponse> content,
        int totalPages,
        long totalElements,
        int page,
        int size
) {
    public static ArtistPageResponse of(Page<ArtistListResponse> page) {
        return ArtistPageResponse.builder()
                .content(page.getContent())
                .totalPages(page.getTotalPages())
                .totalElements(page.getTotalElements())
                .page(page.getNumber())
                .size(page.getSize())
                .build();
    }

    public static ArtistPageResponse of(List<ArtistListResponse> content, int totalPages, long totalElements, int page, int size) {
        return ArtistPageResponse.builder()
                .content(content)
                .totalPages(totalPages)
                .totalElements(totalElements)
                .page(page)
                .size(size)
                .build();
    }
}
