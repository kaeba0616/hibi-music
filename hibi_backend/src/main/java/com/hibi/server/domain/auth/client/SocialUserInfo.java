package com.hibi.server.domain.auth.client;

/**
 * 소셜 제공자로부터 받아오는 사용자 정보
 */
public record SocialUserInfo(
        String email,
        String providerId,
        String profileUrl
) {
}
