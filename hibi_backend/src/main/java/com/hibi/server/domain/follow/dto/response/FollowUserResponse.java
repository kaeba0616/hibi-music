package com.hibi.server.domain.follow.dto.response;

import com.hibi.server.domain.member.entity.Member;
import lombok.Builder;

/**
 * 팔로워/팔로잉 목록 아이템 응답 DTO
 * Flutter의 FollowUser 모델과 매핑
 */
@Builder
public record FollowUserResponse(
        Long id,
        String nickname,
        String username,
        String profileImage,
        Boolean isFollowing
) {
    public static FollowUserResponse from(Member member, boolean isFollowing) {
        return FollowUserResponse.builder()
                .id(member.getId())
                .nickname(member.getNickname())
                .username(extractUsername(member.getEmail()))
                .profileImage(member.getProfileUrl())
                .isFollowing(isFollowing)
                .build();
    }

    /**
     * 이메일에서 username 추출 (@ 앞부분)
     */
    private static String extractUsername(String email) {
        if (email == null || !email.contains("@")) {
            return email;
        }
        return email.substring(0, email.indexOf("@"));
    }
}
