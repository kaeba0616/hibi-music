package com.hibi.server.domain.songlike.entity;

import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.song.entity.Song;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "song_likes", uniqueConstraints = {
        @UniqueConstraint(name = "uk_song_likes_member_song", columnNames = {"member_id", "song_id"})
}, indexes = {
        @Index(name = "idx_song_likes_member", columnList = "member_id"),
        @Index(name = "idx_song_likes_song", columnList = "song_id")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class SongLike {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "song_id", nullable = false)
    private Song song;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    public static SongLike of(Member member, Song song) {
        return SongLike.builder()
                .member(member)
                .song(song)
                .build();
    }
}
