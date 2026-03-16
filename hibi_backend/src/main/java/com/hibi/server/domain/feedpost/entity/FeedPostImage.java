package com.hibi.server.domain.feedpost.entity;

import jakarta.persistence.*;
import lombok.*;

/**
 * 피드 게시글 이미지 Entity
 *
 * 게시글에 첨부된 이미지들을 저장합니다. (최대 4개)
 */
@Entity
@Table(name = "feed_post_images", indexes = {
        @Index(name = "idx_feed_post_images_post", columnList = "feed_post_id")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class FeedPostImage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "feed_post_id", nullable = false)
    private FeedPost feedPost;

    @Column(name = "image_url", nullable = false, length = 512)
    private String imageUrl;

    @Column(name = "order_index", nullable = false)
    private Integer orderIndex;

    public static FeedPostImage of(FeedPost feedPost, String imageUrl, int orderIndex) {
        return FeedPostImage.builder()
                .feedPost(feedPost)
                .imageUrl(imageUrl)
                .orderIndex(orderIndex)
                .build();
    }
}
