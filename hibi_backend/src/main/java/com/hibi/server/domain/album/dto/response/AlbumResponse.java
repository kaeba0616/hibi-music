package com.hibi.server.domain.album.dto.response;

import com.hibi.server.domain.album.entity.Album;
import lombok.Builder;

import java.time.LocalDate;

@Builder
public record AlbumResponse(
        Long id,
        String name,
        String imageUrl,
        LocalDate releaseDate
) {
    public static AlbumResponse from(Album album) {
        if (album == null) {
            return null;
        }
        return AlbumResponse.builder()
                .id(album.getId())
                .name(album.getName())
                .imageUrl(album.getImageUrl())
                .releaseDate(album.getReleaseDate())
                .build();
    }
}
