package com.hibi.server.domain.artist.dto.response;

import com.hibi.server.domain.song.entity.Song;
import lombok.Builder;

/**
 * 아티스트 상세 화면에서 보여줄 노래 응답 DTO
 */
@Builder
public record ArtistSongResponse(
        Long id,
        String titleKor,
        String titleJp,
        String albumName,
        String albumImageUrl,
        Integer releaseYear
) {
    public static ArtistSongResponse from(Song song) {
        String albumName = song.getAlbum() != null ? song.getAlbum().getName() : null;
        String albumImageUrl = song.getAlbum() != null ? song.getAlbum().getImageUrl() : null;
        Integer releaseYear = song.getAlbum() != null && song.getAlbum().getReleaseDate() != null
                ? song.getAlbum().getReleaseDate().getYear()
                : null;

        return ArtistSongResponse.builder()
                .id(song.getId())
                .titleKor(song.getTitleKor())
                .titleJp(song.getTitleJp())
                .albumName(albumName)
                .albumImageUrl(albumImageUrl)
                .releaseYear(releaseYear)
                .build();
    }
}
