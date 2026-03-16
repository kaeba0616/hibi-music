package com.hibi.server.domain.search.dto.response;

import com.hibi.server.domain.member.entity.Member;
import lombok.Builder;

@Builder
public record SearchUserResponse(
        Long id,
        String nickname,
        String username,
        String profileImage,
        Long followerCount
) {
    public static SearchUserResponse from(Member member, Long followerCount) {
        String username = extractUsername(member.getEmail());
        return SearchUserResponse.builder()
                .id(member.getId())
                .nickname(member.getNickname())
                .username(username)
                .profileImage(member.getProfileUrl())
                .followerCount(followerCount)
                .build();
    }

    private static String extractUsername(String email) {
        if (email == null || !email.contains("@")) {
            return "";
        }
        return email.substring(0, email.indexOf("@"));
    }
}
