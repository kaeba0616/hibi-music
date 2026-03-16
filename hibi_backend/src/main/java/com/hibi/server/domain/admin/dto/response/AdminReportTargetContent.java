package com.hibi.server.domain.admin.dto.response;

import lombok.Builder;

import java.time.LocalDateTime;

/**
 * 신고 대상 콘텐츠 정보 응답 DTO (F12)
 */
@Builder
public record AdminReportTargetContent(
        Long id,
        String type,
        String content,
        String authorNickname,
        Long authorId,
        String profileImage,
        LocalDateTime createdAt
) {
    public static AdminReportTargetContent ofPost(Long id, String content, String authorNickname, Long authorId, LocalDateTime createdAt) {
        return AdminReportTargetContent.builder()
                .id(id)
                .type("POST")
                .content(content)
                .authorNickname(authorNickname)
                .authorId(authorId)
                .createdAt(createdAt)
                .build();
    }

    public static AdminReportTargetContent ofComment(Long id, String content, String authorNickname, Long authorId, LocalDateTime createdAt) {
        return AdminReportTargetContent.builder()
                .id(id)
                .type("COMMENT")
                .content(content)
                .authorNickname(authorNickname)
                .authorId(authorId)
                .createdAt(createdAt)
                .build();
    }

    public static AdminReportTargetContent ofMember(Long id, String nickname, String profileImage, LocalDateTime createdAt) {
        return AdminReportTargetContent.builder()
                .id(id)
                .type("MEMBER")
                .authorNickname(nickname)
                .authorId(id)
                .profileImage(profileImage)
                .createdAt(createdAt)
                .build();
    }
}
