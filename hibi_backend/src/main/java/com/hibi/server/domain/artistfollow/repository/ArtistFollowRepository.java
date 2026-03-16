package com.hibi.server.domain.artistfollow.repository;

import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.artistfollow.entity.ArtistFollow;
import com.hibi.server.domain.member.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ArtistFollowRepository extends JpaRepository<ArtistFollow, Long> {

    /**
     * 회원이 특정 아티스트를 팔로우하는지 확인
     */
    boolean existsByMemberAndArtist(Member member, Artist artist);

    /**
     * 회원과 아티스트로 팔로우 정보 조회
     */
    Optional<ArtistFollow> findByMemberAndArtist(Member member, Artist artist);

    /**
     * 회원의 팔로우 정보 삭제
     */
    void deleteByMemberAndArtist(Member member, Artist artist);

    /**
     * 특정 아티스트의 팔로워 수 카운트
     */
    long countByArtist(Artist artist);

    /**
     * 아티스트 ID로 팔로워 수 카운트
     */
    @Query("SELECT COUNT(af) FROM ArtistFollow af WHERE af.artist.id = :artistId")
    long countByArtistId(@Param("artistId") Long artistId);

    /**
     * 회원이 팔로우한 모든 아티스트 조회
     */
    @Query("SELECT af.artist FROM ArtistFollow af WHERE af.member = :member")
    List<Artist> findArtistsByMember(@Param("member") Member member);

    /**
     * 회원이 팔로우한 아티스트 ID 목록 조회
     */
    @Query("SELECT af.artist.id FROM ArtistFollow af WHERE af.member.id = :memberId")
    List<Long> findArtistIdsByMemberId(@Param("memberId") Long memberId);

    /**
     * 회원이 여러 아티스트를 팔로우하는지 확인 (IN 쿼리)
     */
    @Query("SELECT af.artist.id FROM ArtistFollow af WHERE af.member.id = :memberId AND af.artist.id IN :artistIds")
    List<Long> findFollowedArtistIds(@Param("memberId") Long memberId, @Param("artistIds") List<Long> artistIds);
}
