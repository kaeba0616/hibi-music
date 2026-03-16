package com.hibi.server.domain.song.dto.request;

import jakarta.validation.constraints.NotNull;

public record SongCreateRequest(
        @NotNull String titleKor,
        @NotNull String titleEng,
        @NotNull String titleJp,
        @NotNull Long artistId
) {
}
