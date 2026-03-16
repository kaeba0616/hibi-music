package com.hibi.server.domain.song.repository;

import com.hibi.server.domain.song.entity.RelatedSong;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RelatedSongRepository extends JpaRepository<RelatedSong, Long> {

    @Query("SELECT rs FROM RelatedSong rs " +
           "JOIN FETCH rs.relatedSongRef s " +
           "JOIN FETCH s.artist " +
           "LEFT JOIN FETCH s.album " +
           "WHERE rs.song.id = :songId " +
           "ORDER BY rs.displayOrder ASC")
    List<RelatedSong> findBySongIdWithDetails(@Param("songId") Long songId);
}
