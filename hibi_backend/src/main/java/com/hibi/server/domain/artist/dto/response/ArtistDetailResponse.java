package com.hibi.server.domain.artist.dto.response;

import com.hibi.server.domain.artist.entity.Artist;
import lombok.Builder;

import java.util.List;

/**
 * 아티스트 상세 응답 DTO (AC-F3-2)
 * 프로필, 소개, 노래 목록 표시
 */
@Builder
public record ArtistDetailResponse(
        Long id,
        String nameKor,
        String nameEng,
        String nameJp,
        String profileImage,
        String description,
        long followerCount,
        long songCount,
        boolean isFollowing,
        List<ArtistSongResponse> songs
) {
    public static ArtistDetailResponse of(
            Artist artist,
            long followerCount,
            long songCount,
            boolean isFollowing,
            List<ArtistSongResponse> songs
    ) {
        return ArtistDetailResponse.builder()
                .id(artist.getId())
                .nameKor(artist.getNameKor())
                .nameEng(artist.getNameEng())
                .nameJp(artist.getNameJp())
                .profileImage(artist.getProfileUrl())
                .description(artist.getDescription())
                .followerCount(followerCount)
                .songCount(songCount)
                .isFollowing(isFollowing)
                .songs(songs)
                .build();
    }
}
