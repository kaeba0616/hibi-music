package com.hibi.server.domain.artist.dto.response;

import com.hibi.server.domain.artist.entity.Artist;
import lombok.Builder;

/**
 * 아티스트 목록 응답 DTO (AC-F3-1)
 * 이름, 프로필 이미지, 곡 수, 팔로우 상태 표시
 */
@Builder
public record ArtistListResponse(
        Long id,
        String nameKor,
        String nameEng,
        String nameJp,
        String profileImage,
        long songCount,
        boolean isFollowing
) {
    public static ArtistListResponse of(Artist artist, long songCount, boolean isFollowing) {
        return ArtistListResponse.builder()
                .id(artist.getId())
                .nameKor(artist.getNameKor())
                .nameEng(artist.getNameEng())
                .nameJp(artist.getNameJp())
                .profileImage(artist.getProfileUrl())
                .songCount(songCount)
                .isFollowing(isFollowing)
                .build();
    }
}
