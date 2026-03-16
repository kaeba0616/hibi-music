package com.hibi.server.domain.artist.dto.request;


public record ArtistCreateRequest(
        String nameKor,
        String nameEng,
        String nameJp
) {

}
