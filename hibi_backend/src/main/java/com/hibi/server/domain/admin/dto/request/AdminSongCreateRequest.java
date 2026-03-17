package com.hibi.server.domain.admin.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.List;

/**
 * F18: 관리자 곡 등록 요청 (Enhanced)
 */
public record AdminSongCreateRequest(
        @NotBlank String titleKor,
        String titleEng,
        @NotBlank String titleJp,
        @NotNull Long artistId,
        String story,
        String lyricsJp,
        String lyricsKr,
        String youtubeUrl,
        List<RelatedSongInput> relatedSongIds
) {
    public record RelatedSongInput(
            @NotNull Long relatedSongId,
            @NotBlank String reason
    ) {}
}
