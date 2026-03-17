package com.hibi.server.domain.comment.entity;

import com.hibi.server.domain.feedpost.entity.FeedPost;
import com.hibi.server.domain.member.entity.Member;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 댓글 Entity (F6 Comment & Reaction)
 *
 * 게시글(FeedPost)에 달리는 댓글입니다.
 * 대댓글은 parent 필드를 통해 1단계만 지원합니다.
 */
@Entity
@Table(name = "comments", indexes = {
        @Index(name = "idx_comments_feed_post", columnList = "feed_post_id"),
        @Index(name = "idx_comments_member", columnList = "member_id"),
        @Index(name = "idx_comments_parent", columnList = "parent_id"),
        @Index(name = "idx_comments_created_at", columnList = "created_at ASC")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class Comment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "feed_post_id", nullable = false)
    private FeedPost feedPost;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Column(name = "content", nullable = false, length = 500)
    private String content;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id")
    private Comment parent;

    @OneToMany(mappedBy = "parent", cascade = CascadeType.ALL)
    @OrderBy("createdAt ASC")
    @Builder.Default
    private List<Comment> replies = new ArrayList<>();

    @Column(name = "like_count", nullable = false)
    @Builder.Default
    private Integer likeCount = 0;

    @Column(name = "is_deleted", nullable = false)
    @Builder.Default
    private Boolean isDeleted = false;

    /**
     * 부적절 댓글 필터링 여부 (F16: AC-F6-8)
     */
    @Column(name = "is_filtered", nullable = false)
    @Builder.Default
    private Boolean isFiltered = false;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    /**
     * 일반 댓글 생성
     */
    public static Comment of(FeedPost feedPost, Member member, String content) {
        return Comment.builder()
                .feedPost(feedPost)
                .member(member)
                .content(content)
                .build();
    }

    /**
     * 대댓글 생성
     */
    public static Comment ofReply(FeedPost feedPost, Member member, String content, Comment parent) {
        return Comment.builder()
                .feedPost(feedPost)
                .member(member)
                .content(content)
                .parent(parent)
                .build();
    }

    /**
     * 대댓글인지 확인
     */
    public boolean isReply() {
        return this.parent != null;
    }

    /**
     * 본인 댓글인지 확인
     */
    public boolean isAuthor(Long memberId) {
        return this.member.getId().equals(memberId);
    }

    /**
     * 대댓글이 있는지 확인
     */
    public boolean hasReplies() {
        return this.replies != null && !this.replies.isEmpty();
    }

    /**
     * Soft delete (대댓글이 있는 경우)
     */
    public void softDelete() {
        this.isDeleted = true;
        this.content = "";
    }

    /**
     * 부적절 댓글로 필터링 (F16: AC-F6-8)
     */
    public void markAsFiltered() {
        this.isFiltered = true;
    }

    /**
     * 좋아요 수 증가
     */
    public void incrementLikeCount() {
        this.likeCount++;
    }

    /**
     * 좋아요 수 감소
     */
    public void decrementLikeCount() {
        if (this.likeCount > 0) {
            this.likeCount--;
        }
    }

    /**
     * 부모 댓글 작성자 닉네임 반환 (대댓글용)
     */
    public String getParentAuthorNickname() {
        if (this.parent == null) {
            return null;
        }
        if (this.parent.isDeleted) {
            return "삭제됨";
        }
        return this.parent.getMember().getNickname();
    }
}
