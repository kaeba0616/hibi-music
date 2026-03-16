package com.hibi.server.domain.artist.repository;

import com.hibi.server.domain.artist.entity.Artist;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ArtistRepository extends JpaRepository<Artist, Long> {

    /**
     * 이름으로 아티스트 검색 (한글/영문/일본어)
     */
    @Query("SELECT a FROM Artist a WHERE " +
           "LOWER(a.nameKor) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(a.nameEng) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(a.nameJp) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    Page<Artist> searchByName(@Param("keyword") String keyword, Pageable pageable);

    /**
     * 팔로우한 아티스트 목록 조회 (ID 목록)
     */
    @Query("SELECT a FROM Artist a WHERE a.id IN :artistIds")
    Page<Artist> findByIdIn(@Param("artistIds") List<Long> artistIds, Pageable pageable);

    /**
     * 팔로우한 아티스트 중 검색
     */
    @Query("SELECT a FROM Artist a WHERE a.id IN :artistIds AND (" +
           "LOWER(a.nameKor) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(a.nameEng) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(a.nameJp) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Artist> searchByNameInIds(@Param("keyword") String keyword,
                                    @Param("artistIds") List<Long> artistIds,
                                    Pageable pageable);

    /**
     * 아티스트 검색 (List 반환, 통합 검색용)
     */
    @Query("SELECT a FROM Artist a WHERE " +
           "LOWER(a.nameKor) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(a.nameEng) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(a.nameJp) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Artist> searchByKeyword(@Param("keyword") String keyword);
}
