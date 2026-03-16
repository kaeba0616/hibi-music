package com.hibi.server.domain.artist.dto.response;

import com.hibi.server.domain.artist.entity.Artist;
import lombok.Builder;

@Builder
public record ArtistResponse(
        Long id,
        String nameKor,
        String nameEng,
        String nameJp,
        String profileUrl
) {
    public static ArtistResponse from(
            Artist artist
    ) {
        return ArtistResponse.builder()
                .id(artist.getId())
                .nameKor(artist.getNameKor())
                .nameEng(artist.getNameEng())
                .nameJp(artist.getNameJp())
                .profileUrl(artist.getProfileUrl())
                .build();
    }
}
