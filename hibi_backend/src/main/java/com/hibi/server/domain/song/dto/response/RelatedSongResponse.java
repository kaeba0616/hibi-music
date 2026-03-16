package com.hibi.server.domain.song.dto.response;

import com.hibi.server.domain.album.dto.response.AlbumResponse;
import com.hibi.server.domain.artist.dto.response.ArtistResponse;
import com.hibi.server.domain.song.entity.RelatedSong;
import lombok.Builder;

@Builder
public record RelatedSongResponse(
        Long id,
        String titleKor,
        String titleJp,
        ArtistResponse artist,
        AlbumResponse album,
        String reason
) {
    public static RelatedSongResponse from(RelatedSong relatedSong) {
        var song = relatedSong.getRelatedSongRef();
        return RelatedSongResponse.builder()
                .id(song.getId())
                .titleKor(song.getTitleKor())
                .titleJp(song.getTitleJp())
                .artist(ArtistResponse.from(song.getArtist()))
                .album(song.getAlbum() != null ? AlbumResponse.from(song.getAlbum()) : null)
                .reason(relatedSong.getReason())
                .build();
    }
}
