package com.hibi.server.domain.song.dto.response;

import lombok.Builder;

@Builder
public record LyricsResponse(
        String japanese,
        String korean
) {
    public static LyricsResponse of(String lyricsJp, String lyricsKr) {
        return LyricsResponse.builder()
                .japanese(lyricsJp != null ? lyricsJp : "")
                .korean(lyricsKr != null ? lyricsKr : "")
                .build();
    }
}
