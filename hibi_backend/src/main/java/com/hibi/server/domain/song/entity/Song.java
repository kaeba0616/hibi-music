package com.hibi.server.domain.song.entity;

import com.hibi.server.domain.album.entity.Album;
import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.song.dto.request.SongCreateRequest;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "songs", indexes = {
        @Index(name = "idx_songs_artist", columnList = "artist_id"),
        @Index(name = "idx_songs_recommend_date", columnList = "recommend_date")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class Song {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "title_kor", nullable = false, length = 255)
    private String titleKor;

    @Column(name = "title_eng", length = 255)
    private String titleEng;

    @Column(name = "title_jp", nullable = false, length = 255)
    private String titleJp;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "artist_id", nullable = false)
    private Artist artist;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "album_id")
    private Album album;

    @Column(name = "genre", length = 100)
    private String genre;

    @Lob
    @Column(name = "lyrics_jp", columnDefinition = "TEXT")
    private String lyricsJp;

    @Lob
    @Column(name = "lyrics_kr", columnDefinition = "TEXT")
    private String lyricsKr;

    @Column(name = "link_spotify", length = 512)
    private String linkSpotify;

    @Column(name = "link_apple_music", length = 512)
    private String linkAppleMusic;

    @Column(name = "link_youtube", length = 512)
    private String linkYoutube;

    @Column(name = "recommend_date", unique = true)
    private LocalDate recommendDate;

    @Lob
    @Column(name = "story", columnDefinition = "TEXT")
    private String story;

    @Column(name = "scheduled_publish_at")
    private LocalDateTime scheduledPublishAt;

    @Column(name = "is_published", nullable = false)
    @Builder.Default
    private Boolean isPublished = false;

    public static Song of(SongCreateRequest request, Artist artist) {
        return Song.builder()
                .titleKor(request.titleKor())
                .titleEng(request.titleEng())
                .titleJp(request.titleJp())
                .artist(artist)
                .build();
    }

    public static Song of(SongCreateRequest request, Artist artist, Album album) {
        return Song.builder()
                .titleKor(request.titleKor())
                .titleEng(request.titleEng())
                .titleJp(request.titleJp())
                .artist(artist)
                .album(album)
                .build();
    }

    public void updateSong(String titleKor, String titleEng, String titleJp) {
        this.titleKor = titleKor;
        this.titleEng = titleEng;
        this.titleJp = titleJp;
    }

    public void updateAlbum(Album album) {
        this.album = album;
    }

    public void updateLyrics(String lyricsJp, String lyricsKr) {
        this.lyricsJp = lyricsJp;
        this.lyricsKr = lyricsKr;
    }

    public void updateExternalLinks(String linkSpotify, String linkAppleMusic, String linkYoutube) {
        this.linkSpotify = linkSpotify;
        this.linkAppleMusic = linkAppleMusic;
        this.linkYoutube = linkYoutube;
    }

    public void updateGenre(String genre) {
        this.genre = genre;
    }

    public void updateRecommendDate(LocalDate recommendDate) {
        this.recommendDate = recommendDate;
    }

    public void updateStory(String story) {
        this.story = story;
    }

    public void updateScheduledPublishAt(LocalDateTime scheduledPublishAt) {
        this.scheduledPublishAt = scheduledPublishAt;
    }

    public void publish() {
        this.isPublished = true;
    }

    public void cancelSchedule() {
        this.scheduledPublishAt = null;
    }

    /**
     * 곡 정보가 완성되었는지 확인 (예약 게시 가능 여부)
     */
    public boolean isComplete() {
        return titleKor != null && !titleKor.isBlank()
                && titleJp != null && !titleJp.isBlank()
                && artist != null;
    }
}
