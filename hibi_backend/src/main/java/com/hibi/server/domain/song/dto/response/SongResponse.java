package com.hibi.server.domain.song.dto.response;

import com.hibi.server.domain.song.entity.Song;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;

@Builder
public record SongResponse(
        @NotNull Long id,
        @NotNull String titleKor,
        @NotNull String titleEng,
        @NotNull String titleJp,
        @NotNull Long artistId
) {
    public static SongResponse from(Song song) {
        return new SongResponse(
                song.getId(),
                song.getTitleKor(),
                song.getTitleEng(),
                song.getTitleJp(),
                song.getArtist().getId()
        );
    }
}
