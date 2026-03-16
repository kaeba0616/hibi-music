package com.hibi.server.domain.artistfollow.service;

import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.artist.repository.ArtistRepository;
import com.hibi.server.domain.artistfollow.entity.ArtistFollow;
import com.hibi.server.domain.artistfollow.repository.ArtistFollowRepository;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ArtistFollowService {

    private final ArtistFollowRepository artistFollowRepository;
    private final ArtistRepository artistRepository;
    private final MemberRepository memberRepository;

    /**
     * 아티스트 팔로우 (AC-F3-3)
     */
    @Transactional
    public void follow(Long memberId, Long artistId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));
        Artist artist = artistRepository.findById(artistId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        // 이미 팔로우 중인지 확인
        if (artistFollowRepository.existsByMemberAndArtist(member, artist)) {
            throw new CustomException(ErrorCode.DUPLICATE_ENTITY);
        }

        ArtistFollow follow = ArtistFollow.of(member, artist);
        artistFollowRepository.save(follow);
    }

    /**
     * 아티스트 언팔로우 (AC-F3-3)
     */
    @Transactional
    public void unfollow(Long memberId, Long artistId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));
        Artist artist = artistRepository.findById(artistId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        artistFollowRepository.deleteByMemberAndArtist(member, artist);
    }

    /**
     * 팔로우 여부 확인
     */
    public boolean isFollowing(Long memberId, Long artistId) {
        if (memberId == null) return false;

        Member member = memberRepository.findById(memberId).orElse(null);
        Artist artist = artistRepository.findById(artistId).orElse(null);

        if (member == null || artist == null) return false;

        return artistFollowRepository.existsByMemberAndArtist(member, artist);
    }

    /**
     * 아티스트 팔로워 수 조회
     */
    public long getFollowerCount(Long artistId) {
        return artistFollowRepository.countByArtistId(artistId);
    }

    /**
     * 회원이 팔로우한 아티스트 ID 목록 조회
     */
    public List<Long> getFollowedArtistIds(Long memberId) {
        if (memberId == null) return List.of();
        return artistFollowRepository.findArtistIdsByMemberId(memberId);
    }

    /**
     * 회원이 특정 아티스트들을 팔로우하는지 확인 (IN 쿼리)
     */
    public Set<Long> getFollowedArtistIdsIn(Long memberId, List<Long> artistIds) {
        if (memberId == null || artistIds.isEmpty()) return Set.of();
        return artistFollowRepository.findFollowedArtistIds(memberId, artistIds)
                .stream()
                .collect(Collectors.toSet());
    }
}
