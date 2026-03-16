package com.hibi.server.domain.admin.dto.response;

import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.MemberStatus;
import com.hibi.server.domain.member.entity.UserRoleType;
import lombok.Builder;

import java.time.LocalDateTime;

/**
 * 관리자용 회원 정보 응답 DTO (F12)
 */
@Builder
public record AdminMemberResponse(
        Long id,
        String email,
        String nickname,
        String profileImage,
        String role,
        String status,
        LocalDateTime createdAt,
        int postCount,
        int commentCount,
        int followerCount,
        int followingCount,
        int reportReceivedCount,
        int reportSentCount,
        LocalDateTime suspendedUntil,
        String suspendedReason
) {
    public static AdminMemberResponse from(Member member) {
        return AdminMemberResponse.builder()
                .id(member.getId())
                .email(member.getEmail())
                .nickname(member.getNickname())
                .profileImage(member.getProfileUrl())
                .role(member.getRole().name())
                .status(member.getStatus().name())
                .createdAt(member.getCreatedAt())
                .postCount(0) // TODO: 실제 카운트 조회
                .commentCount(0)
                .followerCount(0)
                .followingCount(0)
                .reportReceivedCount(0)
                .reportSentCount(0)
                .suspendedUntil(member.getSuspendedUntil())
                .suspendedReason(member.getSuspendedReason())
                .build();
    }

    public static AdminMemberResponse from(
            Member member,
            int postCount,
            int commentCount,
            int followerCount,
            int followingCount,
            int reportReceivedCount,
            int reportSentCount
    ) {
        return AdminMemberResponse.builder()
                .id(member.getId())
                .email(member.getEmail())
                .nickname(member.getNickname())
                .profileImage(member.getProfileUrl())
                .role(member.getRole().name())
                .status(member.getStatus().name())
                .createdAt(member.getCreatedAt())
                .postCount(postCount)
                .commentCount(commentCount)
                .followerCount(followerCount)
                .followingCount(followingCount)
                .reportReceivedCount(reportReceivedCount)
                .reportSentCount(reportSentCount)
                .suspendedUntil(member.getSuspendedUntil())
                .suspendedReason(member.getSuspendedReason())
                .build();
    }
}
