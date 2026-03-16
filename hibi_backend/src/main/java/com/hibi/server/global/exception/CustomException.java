package com.hibi.server.global.exception;


import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class CustomException extends RuntimeException {
    private final HttpStatus status;
    private final ErrorCode errorCode;

    public CustomException(final String message, final ErrorCode errorCode) {
        super(message);
        this.status = errorCode.getHttpStatus();
        this.errorCode = errorCode;
    }

    public CustomException(ErrorCode errorCode) {
        super(errorCode.getMessage());
        this.status = errorCode.getHttpStatus();
        this.errorCode = errorCode;
    }

}
