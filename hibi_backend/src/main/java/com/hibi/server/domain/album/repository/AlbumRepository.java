package com.hibi.server.domain.album.repository;

import com.hibi.server.domain.album.entity.Album;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AlbumRepository extends JpaRepository<Album, Long> {

    List<Album> findByArtistId(Long artistId);

    List<Album> findByNameContaining(String name);
}
