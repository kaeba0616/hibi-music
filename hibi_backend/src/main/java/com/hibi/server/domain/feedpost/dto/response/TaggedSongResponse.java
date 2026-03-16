package com.hibi.server.domain.feedpost.dto.response;

import com.hibi.server.domain.song.entity.Song;
import lombok.Builder;

/**
 * 태그된 노래 정보 응답 DTO
 * Flutter의 TaggedSong 모델과 매핑
 */
@Builder
public record TaggedSongResponse(
        Long id,
        String titleKor,
        String titleJp,
        String artistName,
        String albumImageUrl,
        String albumName,
        Integer releaseYear
) {
    public static TaggedSongResponse from(Song song) {
        if (song == null) return null;

        return TaggedSongResponse.builder()
                .id(song.getId())
                .titleKor(song.getTitleKor())
                .titleJp(song.getTitleJp())
                .artistName(song.getArtist() != null ? song.getArtist().getNameKor() : null)
                .albumImageUrl(song.getAlbum() != null ? song.getAlbum().getImageUrl() : null)
                .albumName(song.getAlbum() != null ? song.getAlbum().getName() : null)
                .releaseYear(song.getAlbum() != null && song.getAlbum().getReleaseDate() != null
                        ? song.getAlbum().getReleaseDate().getYear() : null)
                .build();
    }
}
