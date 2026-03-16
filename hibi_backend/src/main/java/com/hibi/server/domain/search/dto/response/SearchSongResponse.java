package com.hibi.server.domain.search.dto.response;

import com.hibi.server.domain.song.entity.Song;
import lombok.Builder;

@Builder
public record SearchSongResponse(
        Long id,
        String titleKor,
        String titleJp,
        String artistName,
        String albumName,
        String albumImageUrl
) {
    public static SearchSongResponse from(Song song) {
        return SearchSongResponse.builder()
                .id(song.getId())
                .titleKor(song.getTitleKor())
                .titleJp(song.getTitleJp())
                .artistName(song.getArtist().getNameKor())
                .albumName(song.getAlbum() != null ? song.getAlbum().getName() : null)
                .albumImageUrl(song.getAlbum() != null ? song.getAlbum().getImageUrl() : null)
                .build();
    }
}
