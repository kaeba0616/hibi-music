package com.hibi.server.domain.admin.dto.response;

import lombok.Builder;

import java.util.List;

/**
 * 관리자용 회원 목록 응답 DTO (F12)
 */
@Builder
public record AdminMemberListResponse(
        List<AdminMemberResponse> members,
        int totalCount,
        int page,
        int pageSize
) {
    public static AdminMemberListResponse of(
            List<AdminMemberResponse> members,
            long totalCount,
            int page,
            int pageSize
    ) {
        return AdminMemberListResponse.builder()
                .members(members)
                .totalCount((int) totalCount)
                .page(page)
                .pageSize(pageSize)
                .build();
    }
}
