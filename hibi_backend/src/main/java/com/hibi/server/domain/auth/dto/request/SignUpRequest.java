package com.hibi.server.domain.auth.dto.request;

public record SignUpRequest(
        String email,
        String password,
        String nickname
) {
}