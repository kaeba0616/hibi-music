package com.hibi.server.domain.member.dto.response;

import com.hibi.server.domain.comment.entity.Comment;
import lombok.Builder;

import java.time.LocalDateTime;

/**
 * 내가 쓴 댓글 응답 DTO (F17)
 */
@Builder
public record MyCommentResponse(
        Long commentId,
        String content,
        Integer likeCount,
        LocalDateTime createdAt,
        Long songId,
        String songTitle,
        String artistName
) {
    /**
     * Comment 엔티티와 곡 정보로부터 생성
     */
    public static MyCommentResponse of(Comment comment, Long songId, String songTitle, String artistName) {
        return MyCommentResponse.builder()
                .commentId(comment.getId())
                .content(comment.getContent())
                .likeCount(comment.getLikeCount())
                .createdAt(comment.getCreatedAt())
                .songId(songId)
                .songTitle(songTitle)
                .artistName(artistName)
                .build();
    }
}
