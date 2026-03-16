package com.hibi.server.global.exception;

import lombok.Getter;

@Getter
public class AuthException extends CustomException {

    public AuthException(final ErrorCode errorCode) {
        super("[Auth Exception] " + errorCode.getMessage(), errorCode);
    }
}
