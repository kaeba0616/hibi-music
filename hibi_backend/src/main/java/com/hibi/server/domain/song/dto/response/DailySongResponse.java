package com.hibi.server.domain.song.dto.response;

import com.hibi.server.domain.album.dto.response.AlbumResponse;
import com.hibi.server.domain.artist.dto.response.ArtistResponse;
import com.hibi.server.domain.song.entity.Song;
import lombok.Builder;

import java.time.LocalDate;
import java.util.List;

@Builder
public record DailySongResponse(
        Long id,
        String titleKor,
        String titleJp,
        ArtistResponse artist,
        AlbumResponse album,
        LyricsResponse lyrics,
        String genre,
        LocalDate recommendedDate,
        ExternalLinksResponse externalLinks,
        String youtubeUrl,
        List<RelatedSongResponse> relatedSongs,
        boolean isLiked,
        long likeCount
) {
    public static DailySongResponse from(Song song, boolean isLiked, long likeCount) {
        return from(song, isLiked, likeCount, List.of());
    }

    public static DailySongResponse from(Song song, boolean isLiked, long likeCount, List<RelatedSongResponse> relatedSongs) {
        return DailySongResponse.builder()
                .id(song.getId())
                .titleKor(song.getTitleKor())
                .titleJp(song.getTitleJp())
                .artist(ArtistResponse.from(song.getArtist()))
                .album(AlbumResponse.from(song.getAlbum()))
                .lyrics(LyricsResponse.of(song.getLyricsJp(), song.getLyricsKr()))
                .genre(song.getGenre())
                .recommendedDate(song.getRecommendDate())
                .externalLinks(ExternalLinksResponse.of(
                        song.getLinkSpotify(),
                        song.getLinkAppleMusic(),
                        song.getLinkYoutube()
                ))
                .youtubeUrl(song.getLinkYoutube())
                .relatedSongs(relatedSongs)
                .isLiked(isLiked)
                .likeCount(likeCount)
                .build();
    }

    public static DailySongResponse from(Song song) {
        return from(song, false, 0, List.of());
    }
}
