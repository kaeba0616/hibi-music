package com.hibi.server.domain.post.entity;

import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.post.dto.request.PostCreateRequest;
import com.hibi.server.domain.post.dto.request.PostUpdateRequest;
import com.hibi.server.domain.song.entity.Song;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "posts")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class Post {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "song_id", nullable = false)
    private Song song;

    // 회원 연관관계 (ManyToOne)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Column(length = 100, nullable = false)
    private String title;

    @Column(length = 255, nullable = false)
    private String bio;

    @Column(name = "song_url", length = 512, nullable = false)
    private String songUrl;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "posted_at", nullable = false)
    private LocalDate postedAt;

    public static Post of(PostCreateRequest request, Song song, Member member) {
        return Post.builder()
                .song(song)
                .member(member)
                .title(request.title())
                .bio(request.bio())
                .songUrl(request.songUrl())
                .postedAt(request.postedAt())
                .build();
    }

    public void update(PostUpdateRequest request) {
        this.title = request.title();
        this.bio = request.bio();
        this.songUrl = request.songUrl();
    }

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = this.createdAt;
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
