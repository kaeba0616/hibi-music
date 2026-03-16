package com.hibi.server.domain.auth.dto.request;

public record SignInRequest(
        String email,
        String password
) {
}
