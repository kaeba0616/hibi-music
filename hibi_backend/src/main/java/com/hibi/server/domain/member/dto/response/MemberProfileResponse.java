package com.hibi.server.domain.member.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.hibi.server.domain.member.entity.Member;
import lombok.Builder;

import java.time.LocalDateTime;

import static lombok.AccessLevel.PRIVATE;

@Builder(access = PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public record MemberProfileResponse(
        Long id,
        String email,
        String nickname,
        LocalDateTime createdAt
) {

    public static MemberProfileResponse from(Member member) {
        return MemberProfileResponse.builder()
                .id(member.getId())
                .email(member.getEmail())
                .nickname(member.getNickname())
                .createdAt(member.getCreatedAt())
                .build();
    }

    public static MemberProfileResponse of(
            final String nickname
    ) {
        return MemberProfileResponse.builder()
                .nickname(nickname)
                .build();
    }
}
