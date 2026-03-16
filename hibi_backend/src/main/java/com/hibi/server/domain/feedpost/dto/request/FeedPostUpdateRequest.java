package com.hibi.server.domain.feedpost.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.List;

public record FeedPostUpdateRequest(
        @NotBlank(message = "내용은 필수 입력 값입니다.")
        @Size(max = 500, message = "내용은 500자를 초과할 수 없습니다.")
        String content,

        @Size(max = 4, message = "이미지는 최대 4개까지 첨부할 수 있습니다.")
        List<String> images,

        Long taggedSongId
) {
    public FeedPostUpdateRequest {
        if (images == null) {
            images = List.of();
        }
    }
}
