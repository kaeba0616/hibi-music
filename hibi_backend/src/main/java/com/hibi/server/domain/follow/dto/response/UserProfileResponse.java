package com.hibi.server.domain.follow.dto.response;

import com.hibi.server.domain.member.entity.Member;
import lombok.Builder;

/**
 * 사용자 프로필 응답 DTO
 * Flutter의 UserProfile 모델과 매핑
 */
@Builder
public record UserProfileResponse(
        Long id,
        String nickname,
        String username,
        String profileImage,
        Integer postCount,
        Integer followerCount,
        Integer followingCount,
        Boolean isFollowing
) {
    public static UserProfileResponse from(
            Member member,
            int postCount,
            long followerCount,
            long followingCount,
            boolean isFollowing
    ) {
        return UserProfileResponse.builder()
                .id(member.getId())
                .nickname(member.getNickname())
                .username(extractUsername(member.getEmail()))
                .profileImage(member.getProfileUrl())
                .postCount(postCount)
                .followerCount((int) followerCount)
                .followingCount((int) followingCount)
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
