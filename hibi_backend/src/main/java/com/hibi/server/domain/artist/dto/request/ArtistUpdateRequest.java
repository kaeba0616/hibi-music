package com.hibi.server.domain.artist.dto.request;

public record ArtistUpdateRequest(
        String nameKor,
        String nameEng,
        String nameJp,
        String profileUrl
) {
}
