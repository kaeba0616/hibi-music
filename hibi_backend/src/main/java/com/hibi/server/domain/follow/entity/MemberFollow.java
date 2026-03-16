package com.hibi.server.domain.follow.entity;

import com.hibi.server.domain.member.entity.Member;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * 회원 팔로우 Entity
 * - follower: 팔로우를 하는 사용자
 * - following: 팔로우를 받는 사용자
 */
@Entity
@Table(
    name = "member_follows",
    uniqueConstraints = @UniqueConstraint(
        name = "uk_member_follows_follower_following",
        columnNames = {"follower_id", "following_id"}
    ),
    indexes = {
        @Index(name = "idx_member_follows_follower", columnList = "follower_id"),
        @Index(name = "idx_member_follows_following", columnList = "following_id")
    }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class MemberFollow {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 팔로우를 하는 사용자 (팔로워)
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "follower_id", nullable = false)
    private Member follower;

    /**
     * 팔로우를 받는 사용자 (팔로잉 대상)
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "following_id", nullable = false)
    private Member following;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    /**
     * 팔로우 관계 생성
     */
    public static MemberFollow of(Member follower, Member following) {
        return MemberFollow.builder()
                .follower(follower)
                .following(following)
                .build();
    }
}
