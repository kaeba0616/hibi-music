package com.hibi.server.domain.feedpost.entity;

import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.song.entity.Song;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 피드 게시글 Entity (F5 Post)
 *
 * 소셜 피드에서 사용하는 게시글입니다.
 * 기존 Post Entity는 "오늘의 노래" 추천 게시글용이며, 이 Entity는 소셜 피드 게시글용입니다.
 */
@Entity
@Table(name = "feed_posts", indexes = {
        @Index(name = "idx_feed_posts_member", columnList = "member_id"),
        @Index(name = "idx_feed_posts_created_at", columnList = "created_at DESC")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class FeedPost {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Column(name = "content", nullable = false, length = 500)
    private String content;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "song_id")
    private Song taggedSong;

    @OneToMany(mappedBy = "feedPost", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("orderIndex ASC")
    @Builder.Default
    private List<FeedPostImage> images = new ArrayList<>();

    @Column(name = "like_count", nullable = false)
    @Builder.Default
    private Integer likeCount = 0;

    @Column(name = "comment_count", nullable = false)
    @Builder.Default
    private Integer commentCount = 0;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public static FeedPost of(Member member, String content, Song taggedSong) {
        return FeedPost.builder()
                .member(member)
                .content(content)
                .taggedSong(taggedSong)
                .build();
    }

    public void updateContent(String content) {
        this.content = content;
    }

    public void updateTaggedSong(Song taggedSong) {
        this.taggedSong = taggedSong;
    }

    public void addImage(String imageUrl, int orderIndex) {
        FeedPostImage image = FeedPostImage.of(this, imageUrl, orderIndex);
        this.images.add(image);
    }

    public void clearImages() {
        this.images.clear();
    }

    public void incrementLikeCount() {
        this.likeCount++;
    }

    public void decrementLikeCount() {
        if (this.likeCount > 0) {
            this.likeCount--;
        }
    }

    public void incrementCommentCount() {
        this.commentCount++;
    }

    public void decrementCommentCount() {
        if (this.commentCount > 0) {
            this.commentCount--;
        }
    }

    public boolean isAuthor(Long memberId) {
        return this.member.getId().equals(memberId);
    }
}
