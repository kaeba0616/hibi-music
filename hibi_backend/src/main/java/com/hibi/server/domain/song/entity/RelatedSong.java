package com.hibi.server.domain.song.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "related_songs", indexes = {
        @Index(name = "idx_related_songs_song", columnList = "song_id")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class RelatedSong {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "song_id", nullable = false)
    private Song song;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "related_song_id", nullable = false)
    private Song relatedSongRef;

    @Column(name = "reason", nullable = false, length = 100)
    private String reason;

    @Column(name = "display_order")
    @Builder.Default
    private Integer displayOrder = 0;

    public static RelatedSong of(Song song, Song relatedSong, String reason) {
        return RelatedSong.builder()
                .song(song)
                .relatedSongRef(relatedSong)
                .reason(reason)
                .build();
    }
}
