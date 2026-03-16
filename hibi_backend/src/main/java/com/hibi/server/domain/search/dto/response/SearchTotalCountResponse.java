package com.hibi.server.domain.search.dto.response;

import lombok.Builder;

@Builder
public record SearchTotalCountResponse(
        int songs,
        int artists,
        int posts,
        int users
) {
    public static SearchTotalCountResponse of(int songs, int artists, int posts, int users) {
        return SearchTotalCountResponse.builder()
                .songs(songs)
                .artists(artists)
                .posts(posts)
                .users(users)
                .build();
    }
}
