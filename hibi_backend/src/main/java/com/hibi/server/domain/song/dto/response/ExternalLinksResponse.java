package com.hibi.server.domain.song.dto.response;

import lombok.Builder;

@Builder
public record ExternalLinksResponse(
        String spotify,
        String appleMusic,
        String youtube
) {
    public static ExternalLinksResponse of(String linkSpotify, String linkAppleMusic, String linkYoutube) {
        return ExternalLinksResponse.builder()
                .spotify(linkSpotify)
                .appleMusic(linkAppleMusic)
                .youtube(linkYoutube)
                .build();
    }
}
