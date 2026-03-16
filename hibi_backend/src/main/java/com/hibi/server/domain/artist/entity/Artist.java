package com.hibi.server.domain.artist.entity;

import com.hibi.server.domain.artist.dto.request.ArtistUpdateRequest;
import jakarta.persistence.*;
import lombok.*;

@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Entity
@Table(name = "artists")
@Builder
public class Artist {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name_kor", nullable = false, length = 100)
    private String nameKor;

    @Column(name = "name_eng", length = 100)
    private String nameEng;

    @Column(name = "name_jp", length = 100)
    private String nameJp;

    @Column(name = "profile_url", length = 512)
    private String profileUrl;

    @Lob
    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    public void update(ArtistUpdateRequest request) {
        this.nameKor = request.nameKor();
        this.nameEng = request.nameEng();
        this.nameJp = request.nameJp();
        this.profileUrl = request.profileUrl();
    }

    public void updateDescription(String description) {
        this.description = description;
    }
}
