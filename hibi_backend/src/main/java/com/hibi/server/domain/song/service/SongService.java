package com.hibi.server.domain.song.service;

import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.artist.repository.ArtistRepository;
import com.hibi.server.domain.song.dto.request.SongCreateRequest;
import com.hibi.server.domain.song.dto.request.SongUpdateRequest;
import com.hibi.server.domain.song.dto.response.SongResponse;
import com.hibi.server.domain.song.entity.Song;
import com.hibi.server.domain.song.repository.SongRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SongService {

    private final SongRepository songRepository;
    private final ArtistRepository artistRepository;

    @Transactional
    public void create(SongCreateRequest request) {
        Artist artist = artistRepository.findById(request.artistId())
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        Song song = Song.of(request, artist);
        songRepository.save(song);
    }

    public SongResponse getById(Long id) {
        Song song = songRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        return SongResponse.from(song);
    }

    public SongResponse getByDate(LocalDate date) {
        Song song = songRepository.findByPostedAt(date)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));
        return SongResponse.from(song);
    }

    @Transactional
    public SongResponse update(Long id, SongUpdateRequest request) {
        Song song = songRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        song.updateSong(
                request.titleKor(),
                request.titleEng(),
                request.titleJp()
        );

        return SongResponse.from(song);
    }

    @Transactional
    @PreAuthorize("hasRole('ADMIN')")
    public void delete(Long id) {
        if (!songRepository.existsById(id)) {
            throw new CustomException(ErrorCode.ENTITY_NOT_FOUND);
        }

        songRepository.deleteById(id);
    }

    public List<SongResponse> getAll() {
        return songRepository.findAll().stream()
                .map(SongResponse::from)
                .toList();
    }

    public List<SongResponse> getByMonth(int year, int month) {
        return songRepository.findByPostedAtYearAndMonth(year, month).stream()
                .map(SongResponse::from)
                .toList();
    }
}
