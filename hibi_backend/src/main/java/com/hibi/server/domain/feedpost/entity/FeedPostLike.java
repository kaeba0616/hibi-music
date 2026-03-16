package com.hibi.server.domain.feedpost.entity;

import com.hibi.server.domain.member.entity.Member;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * 피드 게시글 좋아요 Entity
 */
@Entity
@Table(name = "feed_post_likes", uniqueConstraints = {
        @UniqueConstraint(name = "uk_feed_post_likes_member_post", columnNames = {"member_id", "feed_post_id"})
}, indexes = {
        @Index(name = "idx_feed_post_likes_member", columnList = "member_id"),
        @Index(name = "idx_feed_post_likes_post", columnList = "feed_post_id")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class FeedPostLike {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "feed_post_id", nullable = false)
    private FeedPost feedPost;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public static FeedPostLike of(Member member, FeedPost feedPost) {
        return FeedPostLike.builder()
                .member(member)
                .feedPost(feedPost)
                .build();
    }
}
