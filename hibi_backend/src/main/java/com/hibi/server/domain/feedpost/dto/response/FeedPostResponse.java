package com.hibi.server.domain.feedpost.dto.response;

import com.hibi.server.domain.feedpost.entity.FeedPost;
import com.hibi.server.domain.feedpost.entity.FeedPostImage;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 피드 게시글 응답 DTO
 * Flutter의 Post 모델과 매핑
 */
@Builder
public record FeedPostResponse(
        Long id,
        FeedPostAuthorResponse author,
        String content,
        List<String> images,
        TaggedSongResponse taggedSong,
        Integer likeCount,
        Integer commentCount,
        Boolean isLiked,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
    public static FeedPostResponse from(FeedPost feedPost, boolean isLiked) {
        return FeedPostResponse.builder()
                .id(feedPost.getId())
                .author(FeedPostAuthorResponse.from(feedPost.getMember()))
                .content(feedPost.getContent())
                .images(feedPost.getImages().stream()
                        .map(FeedPostImage::getImageUrl)
                        .toList())
                .taggedSong(TaggedSongResponse.from(feedPost.getTaggedSong()))
                .likeCount(feedPost.getLikeCount())
                .commentCount(feedPost.getCommentCount())
                .isLiked(isLiked)
                .createdAt(feedPost.getCreatedAt())
                .updatedAt(feedPost.getUpdatedAt())
                .build();
    }

    public static FeedPostResponse from(FeedPost feedPost) {
        return from(feedPost, false);
    }
}
