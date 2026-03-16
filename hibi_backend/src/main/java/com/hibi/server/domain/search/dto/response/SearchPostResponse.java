package com.hibi.server.domain.search.dto.response;

import com.hibi.server.domain.feedpost.entity.FeedPost;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record SearchPostResponse(
        Long id,
        String content,
        String authorNickname,
        String authorProfileImage,
        Integer likeCount,
        Integer commentCount,
        LocalDateTime createdAt
) {
    public static SearchPostResponse from(FeedPost feedPost) {
        return SearchPostResponse.builder()
                .id(feedPost.getId())
                .content(feedPost.getContent())
                .authorNickname(feedPost.getMember().getNickname())
                .authorProfileImage(feedPost.getMember().getProfileUrl())
                .likeCount(feedPost.getLikeCount())
                .commentCount(feedPost.getCommentCount())
                .createdAt(feedPost.getCreatedAt())
                .build();
    }
}
