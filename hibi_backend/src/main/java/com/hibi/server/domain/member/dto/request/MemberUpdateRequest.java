package com.hibi.server.domain.member.dto.request;

/**
 * 부분 수정 요청: 포함된 필드만 변경된다 (null 필드는 무시).
 */
public record MemberUpdateRequest(
        String nickname,
        String password
) {
}
