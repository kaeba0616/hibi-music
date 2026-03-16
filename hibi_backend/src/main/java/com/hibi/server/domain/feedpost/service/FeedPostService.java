package com.hibi.server.domain.feedpost.service;

import com.hibi.server.domain.feedpost.dto.request.FeedPostCreateRequest;
import com.hibi.server.domain.feedpost.dto.request.FeedPostUpdateRequest;
import com.hibi.server.domain.feedpost.dto.response.FeedPostListResponse;
import com.hibi.server.domain.feedpost.dto.response.FeedPostResponse;
import com.hibi.server.domain.feedpost.entity.FeedPost;
import com.hibi.server.domain.feedpost.entity.FeedPostLike;
import com.hibi.server.domain.feedpost.repository.FeedPostLikeRepository;
import com.hibi.server.domain.feedpost.repository.FeedPostRepository;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.song.entity.Song;
import com.hibi.server.domain.song.repository.SongRepository;
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
public class FeedPostService {

    private final FeedPostRepository feedPostRepository;
    private final FeedPostLikeRepository feedPostLikeRepository;
    private final MemberRepository memberRepository;
    private final SongRepository songRepository;

    /**
     * 피드 게시글 목록 조회 (페이징)
     */
    public FeedPostListResponse getPosts(int page, int size, Long currentMemberId) {
        Pageable pageable = PageRequest.of(page, size);
        Page<FeedPost> feedPosts = feedPostRepository.findAllOrderByCreatedAtDesc(pageable);

        // 현재 사용자의 좋아요 여부 조회
        Set<Long> likedPostIds = getLikedPostIds(
                feedPosts.getContent().stream().map(FeedPost::getId).toList(),
                currentMemberId
        );

        Page<FeedPostResponse> responsePage = feedPosts.map(post ->
                FeedPostResponse.from(post, likedPostIds.contains(post.getId()))
        );

        return FeedPostListResponse.from(responsePage);
    }

    /**
     * 게시글 상세 조회
     */
    public FeedPostResponse getPost(Long postId, Long currentMemberId) {
        FeedPost feedPost = feedPostRepository.findWithDetailsById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        boolean isLiked = currentMemberId != null &&
                feedPostLikeRepository.existsByMemberIdAndFeedPostId(currentMemberId, postId);

        return FeedPostResponse.from(feedPost, isLiked);
    }

    /**
     * 게시글 작성
     */
    @Transactional
    public FeedPostResponse createPost(FeedPostCreateRequest request, Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        Song taggedSong = null;
        if (request.taggedSongId() != null) {
            taggedSong = songRepository.findById(request.taggedSongId())
                    .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));
        }

        FeedPost feedPost = FeedPost.of(member, request.content(), taggedSong);

        // 이미지 추가
        for (int i = 0; i < request.images().size(); i++) {
            feedPost.addImage(request.images().get(i), i);
        }

        FeedPost saved = feedPostRepository.save(feedPost);
        return FeedPostResponse.from(saved, false);
    }

    /**
     * 게시글 수정
     */
    @Transactional
    public FeedPostResponse updatePost(Long postId, FeedPostUpdateRequest request, Long memberId) {
        FeedPost feedPost = feedPostRepository.findWithDetailsById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        // 작성자 확인
        if (!feedPost.isAuthor(memberId)) {
            throw new CustomException(ErrorCode.UNAUTHORIZED_ACCESS);
        }

        // 내용 수정
        feedPost.updateContent(request.content());

        // 태그 노래 수정
        Song taggedSong = null;
        if (request.taggedSongId() != null) {
            taggedSong = songRepository.findById(request.taggedSongId())
                    .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));
        }
        feedPost.updateTaggedSong(taggedSong);

        // 이미지 수정 (기존 이미지 삭제 후 새로 추가)
        feedPost.clearImages();
        for (int i = 0; i < request.images().size(); i++) {
            feedPost.addImage(request.images().get(i), i);
        }

        boolean isLiked = feedPostLikeRepository.existsByMemberIdAndFeedPostId(memberId, postId);
        return FeedPostResponse.from(feedPost, isLiked);
    }

    /**
     * 게시글 삭제
     */
    @Transactional
    public void deletePost(Long postId, Long memberId) {
        FeedPost feedPost = feedPostRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        // 작성자 확인
        if (!feedPost.isAuthor(memberId)) {
            throw new CustomException(ErrorCode.UNAUTHORIZED_ACCESS);
        }

        feedPostRepository.delete(feedPost);
    }

    /**
     * 좋아요 토글
     */
    @Transactional
    public boolean toggleLike(Long postId, Long memberId) {
        FeedPost feedPost = feedPostRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        boolean exists = feedPostLikeRepository.existsByMemberIdAndFeedPostId(memberId, postId);

        if (exists) {
            // 좋아요 취소
            feedPostLikeRepository.deleteByMemberIdAndFeedPostId(memberId, postId);
            feedPost.decrementLikeCount();
            return false;
        } else {
            // 좋아요 추가
            FeedPostLike like = FeedPostLike.of(member, feedPost);
            feedPostLikeRepository.save(like);
            feedPost.incrementLikeCount();
            return true;
        }
    }

    /**
     * 특정 사용자의 게시글 목록 조회
     */
    public FeedPostListResponse getUserPosts(Long userId, int page, int size, Long currentMemberId) {
        Pageable pageable = PageRequest.of(page, size);
        Page<FeedPost> feedPosts = feedPostRepository.findByMemberIdOrderByCreatedAtDesc(userId, pageable);

        // 현재 사용자의 좋아요 여부 조회
        Set<Long> likedPostIds = getLikedPostIds(
                feedPosts.getContent().stream().map(FeedPost::getId).toList(),
                currentMemberId
        );

        Page<FeedPostResponse> responsePage = feedPosts.map(post ->
                FeedPostResponse.from(post, likedPostIds.contains(post.getId()))
        );

        return FeedPostListResponse.from(responsePage);
    }

    /**
     * 팔로잉 피드 조회 (팔로우하는 사용자들의 게시글)
     */
    public FeedPostListResponse getFollowingFeed(List<Long> followingIds, int page, int size, Long currentMemberId) {
        if (followingIds.isEmpty()) {
            return FeedPostListResponse.empty();
        }

        Pageable pageable = PageRequest.of(page, size);
        Page<FeedPost> feedPosts = feedPostRepository.findByMemberIdInOrderByCreatedAtDesc(followingIds, pageable);

        // 현재 사용자의 좋아요 여부 조회
        Set<Long> likedPostIds = getLikedPostIds(
                feedPosts.getContent().stream().map(FeedPost::getId).toList(),
                currentMemberId
        );

        Page<FeedPostResponse> responsePage = feedPosts.map(post ->
                FeedPostResponse.from(post, likedPostIds.contains(post.getId()))
        );

        return FeedPostListResponse.from(responsePage);
    }

    /**
     * 여러 게시글에 대한 좋아요 여부 조회 (N+1 방지)
     */
    private Set<Long> getLikedPostIds(List<Long> postIds, Long memberId) {
        if (memberId == null || postIds.isEmpty()) {
            return Set.of();
        }

        return postIds.stream()
                .filter(postId -> feedPostLikeRepository.existsByMemberIdAndFeedPostId(memberId, postId))
                .collect(Collectors.toSet());
    }
}
