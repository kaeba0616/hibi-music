package com.hibi.server.domain.post.dto.response;

import com.hibi.server.domain.post.entity.Post;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;

import java.time.LocalDate;

@Builder
public record PostResponse(
        @NotNull Long id,
        @NotNull String title,
        @NotNull String bio,
        @NotNull String songUrl,
        @NotNull LocalDate postedAt,
        @NotNull String artistNameKor,
        @NotNull String artistNameEng,
        @NotNull String artistNameJp
) {
    public static PostResponse from(Post post) {
        return PostResponse.builder()
                .id(post.getId())
                .title(post.getTitle())
                .bio(post.getBio())
                .songUrl(post.getSongUrl())
                .postedAt(post.getPostedAt())
                .artistNameKor(post.getSong().getArtist().getNameKor())
                .artistNameEng(post.getSong().getArtist().getNameEng())
                .artistNameJp(post.getSong().getArtist().getNameJp())
                .build();
    }
}
