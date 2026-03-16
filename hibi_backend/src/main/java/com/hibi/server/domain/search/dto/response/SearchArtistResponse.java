package com.hibi.server.domain.search.dto.response;

import com.hibi.server.domain.artist.entity.Artist;
import lombok.Builder;

@Builder
public record SearchArtistResponse(
        Long id,
        String nameKor,
        String nameEng,
        String nameJp,
        String profileUrl,
        Long followerCount
) {
    public static SearchArtistResponse from(Artist artist, Long followerCount) {
        return SearchArtistResponse.builder()
                .id(artist.getId())
                .nameKor(artist.getNameKor())
                .nameEng(artist.getNameEng())
                .nameJp(artist.getNameJp())
                .profileUrl(artist.getProfileUrl())
                .followerCount(followerCount)
                .build();
    }
}
