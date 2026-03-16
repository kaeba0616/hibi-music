package com.hibi.server.global.response;

import jakarta.validation.constraints.NotNull;

public interface ApiResponse {
    @NotNull
    boolean success();

    @NotNull
    String message();
}
