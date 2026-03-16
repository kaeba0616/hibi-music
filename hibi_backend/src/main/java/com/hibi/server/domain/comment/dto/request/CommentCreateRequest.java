package com.hibi.server.domain.comment.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * 댓글 작성 요청 DTO
 */
public record CommentCreateRequest(
        @NotBlank(message = "댓글 내용은 필수입니다")
        @Size(max = 500, message = "댓글은 500자 이하로 입력해주세요")
        String content,

        Long parentId
) {
}
