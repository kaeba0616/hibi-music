package com.hibi.server.domain.member.dto.request;

import jakarta.validation.constraints.NotNull;

public record MemberUpdateRequest(
        @NotNull String nickname,
        @NotNull String password
) {
}
