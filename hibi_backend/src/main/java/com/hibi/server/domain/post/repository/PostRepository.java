package com.hibi.server.domain.post.repository;

import com.hibi.server.domain.post.dto.response.PostResponse;
import com.hibi.server.domain.post.entity.Post;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface PostRepository extends JpaRepository<Post, Long> {
    //TODO: N+1 문제가 해결되었는지 체크하기

    @EntityGraph(attributePaths = {"song", "song.artist"})
    Optional<Post> findById(Long id);

    @Query("""
                SELECT new com.hibi.server.domain.post.dto.response.PostResponse(
                    p.id, p.title, p.bio, p.songUrl, p.postedAt,
                    a.nameKor, a.nameEng, a.nameJp
                )
                FROM Post p
                JOIN p.song s
                JOIN s.artist a
            """)
    List<PostResponse> findAllAsDto();

    @Query("""
                SELECT new com.hibi.server.domain.post.dto.response.PostResponse(
                    p.id, p.title, p.bio, p.songUrl, p.postedAt,
                    a.nameKor, a.nameEng, a.nameJp
                )
                FROM Post p
                JOIN p.song s
                JOIN s.artist a
                WHERE p.postedAt = :date
            """)
    Optional<PostResponse> findByPostedAt(@Param("date") LocalDate date);

    @Query("""
                SELECT new com.hibi.server.domain.post.dto.response.PostResponse(
                    p.id, p.title, p.bio, p.songUrl, p.postedAt,
                    a.nameKor, a.nameEng, a.nameJp
                )
                FROM Post p
                JOIN p.song s
                JOIN s.artist a
                WHERE p.postedAt BETWEEN :startDate AND :endDate
            """)
    List<PostResponse> findByPostedAtBetween(
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    boolean existsByPostedAt(LocalDate postedAt);
}
