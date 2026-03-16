package com.hibi.server.domain.comment.entity;

import com.hibi.server.domain.member.entity.Member;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * 댓글 좋아요 Entity
 */
@Entity
@Table(name = "comment_likes", uniqueConstraints = {
        @UniqueConstraint(name = "uk_comment_likes_member_comment", columnNames = {"member_id", "comment_id"})
}, indexes = {
        @Index(name = "idx_comment_likes_member", columnList = "member_id"),
        @Index(name = "idx_comment_likes_comment", columnList = "comment_id")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class CommentLike {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comment_id", nullable = false)
    private Comment comment;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public static CommentLike of(Member member, Comment comment) {
        return CommentLike.builder()
                .member(member)
                .comment(comment)
                .build();
    }
}
