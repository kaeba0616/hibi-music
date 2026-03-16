package com.hibi.server.domain.follow.dto.response;

import lombok.Builder;

import java.util.List;

/**
 * 팔로워/팔로잉 목록 응답 DTO
 * Flutter의 FollowListResponse 모델과 매핑
 */
@Builder
public record FollowListResponse(
        List<FollowUserResponse> content,
        Integer totalCount,
        Boolean hasMore
) {
    public static FollowListResponse of(List<FollowUserResponse> users, int totalCount, boolean hasMore) {
        return FollowListResponse.builder()
                .content(users)
                .totalCount(totalCount)
                .hasMore(hasMore)
                .build();
    }
}
