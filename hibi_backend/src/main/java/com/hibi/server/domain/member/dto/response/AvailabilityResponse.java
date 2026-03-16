package com.hibi.server.domain.member.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.Builder;

@Builder(access = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public record AvailabilityResponse(
        boolean available,
        String nickname,
        String email
) {

    public static AvailabilityResponse forNickname(final String nickname, final boolean available) {
        return AvailabilityResponse.builder()
                .available(available)
                .nickname(nickname)
                .build();
    }

    public static AvailabilityResponse forEmail(final String email, final boolean available) {
        return AvailabilityResponse.builder()
                .available(available)
                .email(email)
                .build();
    }
}
