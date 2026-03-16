package com.hibi.server.domain.follow.service;

import com.hibi.server.domain.feedpost.repository.FeedPostRepository;
import com.hibi.server.domain.follow.dto.response.FollowListResponse;
import com.hibi.server.domain.follow.dto.response.FollowUserResponse;
import com.hibi.server.domain.follow.dto.response.UserProfileResponse;
import com.hibi.server.domain.follow.entity.MemberFollow;
import com.hibi.server.domain.follow.repository.MemberFollowRepository;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FollowService {

    private final MemberFollowRepository memberFollowRepository;
    private final MemberRepository memberRepository;
    private final FeedPostRepository feedPostRepository;

    /**
     * 사용자 프로필 조회
     */
    public UserProfileResponse getUserProfile(Long targetUserId, Long currentUserId) {
        Member targetMember = memberRepository.findById(targetUserId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        // 삭제된 사용자 확인
        if (targetMember.isDeleted()) {
            throw new CustomException(ErrorCode.ENTITY_NOT_FOUND);
        }

        // 게시글 수 조회
        int postCount = (int) feedPostRepository.findByMemberIdOrderByCreatedAtDesc(
                targetUserId, PageRequest.of(0, 1)).getTotalElements();

        // 팔로워/팔로잉 수 조회
        long followerCount = memberFollowRepository.countFollowersByUserId(targetUserId);
        long followingCount = memberFollowRepository.countFollowingsByUserId(targetUserId);

        // 현재 사용자의 팔로우 여부
        boolean isFollowing = false;
        if (currentUserId != null && !currentUserId.equals(targetUserId)) {
            isFollowing = memberFollowRepository.existsByFollowerIdAndFollowingId(currentUserId, targetUserId);
        }

        return UserProfileResponse.from(
                targetMember,
                postCount,
                followerCount,
                followingCount,
                isFollowing
        );
    }

    /**
     * 팔로워 목록 조회
     */
    public FollowListResponse getFollowers(Long userId, Long currentUserId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<MemberFollow> followersPage = memberFollowRepository.findFollowersByUserId(userId, pageable);

        // 팔로워들의 ID 목록
        List<Long> followerIds = followersPage.getContent().stream()
                .map(mf -> mf.getFollower().getId())
                .toList();

        // 현재 사용자가 팔로워들 중 누구를 팔로우하는지 확인
        Set<Long> followingIds = getFollowingIdsAmong(currentUserId, followerIds);

        List<FollowUserResponse> users = followersPage.getContent().stream()
                .map(mf -> {
                    Member follower = mf.getFollower();
                    boolean isFollowing = currentUserId != null &&
                            !currentUserId.equals(follower.getId()) &&
                            followingIds.contains(follower.getId());
                    return FollowUserResponse.from(follower, isFollowing);
                })
                .toList();

        return FollowListResponse.of(
                users,
                (int) followersPage.getTotalElements(),
                followersPage.hasNext()
        );
    }

    /**
     * 팔로잉 목록 조회
     */
    public FollowListResponse getFollowings(Long userId, Long currentUserId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<MemberFollow> followingsPage = memberFollowRepository.findFollowingsByUserId(userId, pageable);

        // 팔로잉들의 ID 목록
        List<Long> followingIds = followingsPage.getContent().stream()
                .map(mf -> mf.getFollowing().getId())
                .toList();

        // 현재 사용자가 팔로잉 중인 사람들 확인
        Set<Long> currentUserFollowingIds = getFollowingIdsAmong(currentUserId, followingIds);

        List<FollowUserResponse> users = followingsPage.getContent().stream()
                .map(mf -> {
                    Member following = mf.getFollowing();
                    boolean isFollowing = currentUserId != null &&
                            !currentUserId.equals(following.getId()) &&
                            currentUserFollowingIds.contains(following.getId());
                    return FollowUserResponse.from(following, isFollowing);
                })
                .toList();

        return FollowListResponse.of(
                users,
                (int) followingsPage.getTotalElements(),
                followingsPage.hasNext()
        );
    }

    /**
     * 팔로우
     */
    @Transactional
    public void follow(Long targetUserId, Long currentUserId) {
        // 자기 자신을 팔로우할 수 없음
        if (targetUserId.equals(currentUserId)) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }

        // 대상 사용자 존재 확인
        Member targetMember = memberRepository.findById(targetUserId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        if (targetMember.isDeleted()) {
            throw new CustomException(ErrorCode.ENTITY_NOT_FOUND);
        }

        // 현재 사용자 조회
        Member currentMember = memberRepository.findById(currentUserId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        // 이미 팔로우 중인지 확인
        boolean alreadyFollowing = memberFollowRepository.existsByFollowerIdAndFollowingId(
                currentUserId, targetUserId);

        if (alreadyFollowing) {
            throw new CustomException(ErrorCode.ALREADY_EXISTS);
        }

        // 팔로우 관계 생성
        MemberFollow follow = MemberFollow.of(currentMember, targetMember);
        memberFollowRepository.save(follow);
    }

    /**
     * 언팔로우
     */
    @Transactional
    public void unfollow(Long targetUserId, Long currentUserId) {
        // 자기 자신을 언팔로우할 수 없음
        if (targetUserId.equals(currentUserId)) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }

        // 팔로우 관계 확인
        MemberFollow follow = memberFollowRepository
                .findByFollowerIdAndFollowingId(currentUserId, targetUserId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        memberFollowRepository.delete(follow);
    }

    /**
     * 팔로우 여부 확인
     */
    public boolean isFollowing(Long followerId, Long followingId) {
        return memberFollowRepository.existsByFollowerIdAndFollowingId(followerId, followingId);
    }

    /**
     * 현재 사용자가 팔로우하는 사용자 ID 목록 조회
     */
    public List<Long> getFollowingIds(Long userId) {
        return memberFollowRepository.findFollowingIdsByUserId(userId);
    }

    /**
     * 특정 사용자들 중 현재 사용자가 팔로우하는 사용자 ID 집합
     */
    private Set<Long> getFollowingIdsAmong(Long currentUserId, List<Long> targetUserIds) {
        if (currentUserId == null || targetUserIds.isEmpty()) {
            return Set.of();
        }
        return memberFollowRepository.findFollowingIdsAmong(currentUserId, targetUserIds)
                .stream()
                .collect(Collectors.toSet());
    }
}
