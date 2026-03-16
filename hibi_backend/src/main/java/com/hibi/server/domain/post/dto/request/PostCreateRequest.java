package com.hibi.server.domain.post.dto.request;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

public record PostCreateRequest(
        @NotNull Long songId,
        @NotNull Long memberId,
        @NotNull String title,
        @NotNull String bio,
        @NotNull String songUrl,
        @NotNull LocalDate postedAt
) {

}

