package com.hibi.server.domain.search.dto.response;

import lombok.Builder;

import java.util.List;

@Builder
public record SearchResponse(
        String keyword,
        List<SearchSongResponse> songs,
        List<SearchArtistResponse> artists,
        List<SearchPostResponse> posts,
        List<SearchUserResponse> users,
        SearchTotalCountResponse totalCount
) {
    public static SearchResponse of(
            String keyword,
            List<SearchSongResponse> songs,
            List<SearchArtistResponse> artists,
            List<SearchPostResponse> posts,
            List<SearchUserResponse> users
    ) {
        return SearchResponse.builder()
                .keyword(keyword)
                .songs(songs)
                .artists(artists)
                .posts(posts)
                .users(users)
                .totalCount(SearchTotalCountResponse.of(
                        songs.size(),
                        artists.size(),
                        posts.size(),
                        users.size()
                ))
                .build();
    }

    public static SearchResponse empty(String keyword) {
        return SearchResponse.builder()
                .keyword(keyword)
                .songs(List.of())
                .artists(List.of())
                .posts(List.of())
                .users(List.of())
                .totalCount(SearchTotalCountResponse.of(0, 0, 0, 0))
                .build();
    }
}
