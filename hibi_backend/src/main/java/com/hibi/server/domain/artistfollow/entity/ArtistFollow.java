package com.hibi.server.domain.artistfollow.entity;

import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.member.entity.Member;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * 아티스트 팔로우 Entity
 * Member(N) ↔ Artist(M) 다대다 관계를 풀어낸 조인 테이블
 */
@Entity
@Table(name = "artist_follows",
        uniqueConstraints = {
            @UniqueConstraint(
                name = "uk_artist_follows_member_artist",
                columnNames = {"member_id", "artist_id"}
            )
        },
        indexes = {
            @Index(name = "idx_artist_follows_member", columnList = "member_id"),
            @Index(name = "idx_artist_follows_artist", columnList = "artist_id")
        })
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class ArtistFollow {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "artist_id", nullable = false)
    private Artist artist;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    public static ArtistFollow of(Member member, Artist artist) {
        return ArtistFollow.builder()
                .member(member)
                .artist(artist)
                .build();
    }
}
