package com.hibi.server.domain.song.repository;

import com.hibi.server.domain.song.entity.Song;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface SongRepository extends JpaRepository<Song, Long> {

    List<Song> findByArtistId(Long artistId);

    List<Song> findByAlbumId(Long albumId);

    /**
     * 아티스트별 노래 수 카운트
     */
    long countByArtistId(Long artistId);

    /**
     * 추천 날짜로 노래 조회 (Daily Song)
     */
    Optional<Song> findByRecommendDate(LocalDate recommendDate);

    /**
     * 특정 연/월의 추천 노래 목록
     */
    @Query("SELECT s FROM Song s WHERE YEAR(s.recommendDate) = :year AND MONTH(s.recommendDate) = :month ORDER BY s.recommendDate DESC")
    List<Song> findByRecommendDateYearAndMonth(@Param("year") int year, @Param("month") int month);

    /**
     * 추천 날짜가 있는 노래 목록 (최신순)
     */
    List<Song> findByRecommendDateIsNotNullOrderByRecommendDateDesc();

    /**
     * Post 기반 조회 (기존 호환성 유지)
     */
    @Query("SELECT p.song FROM Post p WHERE p.postedAt = :postedAt")
    Optional<Song> findByPostedAt(@Param("postedAt") LocalDate postedAt);

    @Query("SELECT p.song FROM Post p WHERE YEAR(p.postedAt) = :year AND MONTH(p.postedAt) = :month")
    List<Song> findByPostedAtYearAndMonth(@Param("year") int year, @Param("month") int month);

    /**
     * 노래 검색 (제목 한글/일본어, 아티스트명으로 검색)
     */
    @Query("SELECT s FROM Song s JOIN FETCH s.artist a LEFT JOIN FETCH s.album " +
           "WHERE LOWER(s.titleKor) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(s.titleJp) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(a.nameKor) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(a.nameEng) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(a.nameJp) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Song> searchByKeyword(@Param("keyword") String keyword);
}
