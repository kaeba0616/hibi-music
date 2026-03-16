package com.hibi.server.domain.album.entity;

import com.hibi.server.domain.artist.entity.Artist;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "albums")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder
public class Album {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, length = 255)
    private String name;

    @Column(name = "image_url", length = 512)
    private String imageUrl;

    @Column(name = "release_date")
    private LocalDate releaseDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "artist_id", nullable = false)
    private Artist artist;

    public static Album of(String name, String imageUrl, LocalDate releaseDate, Artist artist) {
        return Album.builder()
                .name(name)
                .imageUrl(imageUrl)
                .releaseDate(releaseDate)
                .artist(artist)
                .build();
    }

    public void update(String name, String imageUrl, LocalDate releaseDate) {
        this.name = name;
        this.imageUrl = imageUrl;
        this.releaseDate = releaseDate;
    }
}
