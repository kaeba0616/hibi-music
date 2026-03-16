package com.hibi.server.domain.auth.dto.response;

import com.hibi.server.domain.member.entity.UserRoleType;
import jakarta.validation.constraints.NotNull;
import lombok.Builder;

import static lombok.AccessLevel.PRIVATE;

@Builder(access = PRIVATE)
public record SocialLoginResponse(
        @NotNull String accessToken,
        @NotNull String refreshToken,
        @NotNull Long memberId,
        @NotNull UserRoleType roleType,
        @NotNull boolean isNewUser
) {

    public static SocialLoginResponse of(
            final String accessToken,
            final String refreshToken,
            final Long memberId,
            final UserRoleType roleType,
            final boolean isNewUser) {
        return SocialLoginResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .memberId(memberId)
                .roleType(roleType)
                .isNewUser(isNewUser)
                .build();
    }
}
