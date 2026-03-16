package com.hibi.server.domain.comment.dto.response;

import com.hibi.server.domain.member.entity.Member;
import lombok.Builder;

/**
 * 댓글 작성자 응답 DTO
 * Flutter의 CommentAuthor 모델과 매핑
 */
@Builder
public record CommentAuthorResponse(
        Long id,
        String nickname,
        String username,
        String profileImage
) {
    public static CommentAuthorResponse from(Member member) {
        if (member == null) {
            return null;
        }
        return CommentAuthorResponse.builder()
                .id(member.getId())
                .nickname(member.getNickname())
                .username(member.getEmail().split("@")[0])
                .profileImage(member.getProfileUrl())
                .build();
    }

    /**
     * 삭제된 댓글용 작성자 정보
     */
    public static CommentAuthorResponse deleted() {
        return CommentAuthorResponse.builder()
                .id(0L)
                .nickname("")
                .username("")
                .profileImage(null)
                .build();
    }
}
