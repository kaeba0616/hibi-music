package com.hibi.server.domain.post.dto.request;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

// PostUpdateRequest.java
public record PostUpdateRequest(
        @NotNull String title,
        @NotNull String bio,
        @NotNull String songUrl,
        @NotNull LocalDate postedAt
) {
}
