package com.hibi.server.domain.feedpost.dto.response;

import com.hibi.server.domain.member.entity.Member;
import lombok.Builder;

/**
 * 게시글 작성자 정보 응답 DTO
 * Flutter의 PostAuthor 모델과 매핑
 */
@Builder
public record FeedPostAuthorResponse(
        Long id,
        String nickname,
        String username,
        String profileImage
) {
    public static FeedPostAuthorResponse from(Member member) {
        return FeedPostAuthorResponse.builder()
                .id(member.getId())
                .nickname(member.getNickname())
                .username(member.getEmail().split("@")[0]) // email에서 username 추출
                .profileImage(member.getProfileUrl())
                .build();
    }
}
