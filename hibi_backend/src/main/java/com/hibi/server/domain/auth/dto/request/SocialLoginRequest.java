package com.hibi.server.domain.auth.dto.request;

import com.hibi.server.domain.member.entity.ProviderType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record SocialLoginRequest(
        @NotNull(message = "소셜 로그인 제공자는 필수입니다")
        ProviderType provider,

        @NotBlank(message = "소셜 인증 토큰은 필수입니다")
        String accessToken,

        String nickname
) {}
