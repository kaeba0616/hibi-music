package com.hibi.server.domain.comment.service;

import com.hibi.server.domain.comment.dto.request.CommentCreateRequest;
import com.hibi.server.domain.comment.dto.response.CommentListResponse;
import com.hibi.server.domain.comment.dto.response.CommentResponse;
import com.hibi.server.domain.comment.entity.Comment;
import com.hibi.server.domain.comment.entity.CommentLike;
import com.hibi.server.domain.comment.repository.CommentLikeRepository;
import com.hibi.server.domain.comment.repository.CommentRepository;
import com.hibi.server.domain.feedpost.entity.FeedPost;
import com.hibi.server.domain.feedpost.repository.FeedPostRepository;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CommentService {

    private final CommentRepository commentRepository;
    private final CommentLikeRepository commentLikeRepository;
    private final FeedPostRepository feedPostRepository;
    private final MemberRepository memberRepository;

    /**
     * 게시글의 댓글 목록 조회
     */
    public CommentListResponse getComments(Long postId, Long currentMemberId) {
        // 최상위 댓글만 조회 (대댓글 제외)
        List<Comment> topLevelComments = commentRepository.findTopLevelCommentsByFeedPostId(postId);

        // 모든 댓글 ID 수집 (최상위 + 대댓글)
        List<Long> allCommentIds = new ArrayList<>();
        for (Comment comment : topLevelComments) {
            allCommentIds.add(comment.getId());
            allCommentIds.addAll(comment.getReplies().stream().map(Comment::getId).toList());
        }

        // 좋아요 여부 조회
        Set<Long> likedCommentIds = getLikedCommentIds(allCommentIds, currentMemberId);

        // 응답 변환
        List<CommentResponse> responses = topLevelComments.stream()
                .map(comment -> {
                    List<CommentResponse> replies = comment.getReplies().stream()
                            .map(reply -> CommentResponse.fromReply(reply, likedCommentIds.contains(reply.getId())))
                            .toList();
                    return CommentResponse.from(comment, likedCommentIds.contains(comment.getId()), replies);
                })
                .toList();

        int totalCount = commentRepository.countByFeedPostId(postId);
        return CommentListResponse.of(responses, totalCount);
    }

    /**
     * 댓글 작성
     */
    @Transactional
    public CommentResponse createComment(Long postId, CommentCreateRequest request, Long memberId) {
        FeedPost feedPost = feedPostRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        Comment comment;
        if (request.parentId() != null) {
            // 대댓글 작성
            Comment parent = commentRepository.findById(request.parentId())
                    .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

            // 대대댓글 방지
            if (parent.getParent() != null) {
                throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
            }

            comment = Comment.ofReply(feedPost, member, request.content(), parent);
        } else {
            // 일반 댓글 작성
            comment = Comment.of(feedPost, member, request.content());
        }

        Comment saved = commentRepository.save(comment);

        // 게시글 댓글 수 증가
        feedPost.incrementCommentCount();

        return CommentResponse.from(saved, false, List.of());
    }

    /**
     * 댓글 삭제
     */
    @Transactional
    public void deleteComment(Long commentId, Long memberId) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        // 작성자 확인
        if (!comment.isAuthor(memberId)) {
            throw new CustomException(ErrorCode.UNAUTHORIZED_ACCESS);
        }

        FeedPost feedPost = comment.getFeedPost();

        if (comment.hasReplies()) {
            // 대댓글이 있으면 soft delete
            comment.softDelete();
        } else {
            // 대댓글이 없으면 hard delete
            // 먼저 좋아요 삭제
            commentLikeRepository.deleteByCommentId(commentId);
            commentRepository.delete(comment);
        }

        // 게시글 댓글 수 감소
        feedPost.decrementCommentCount();
    }

    /**
     * 댓글 좋아요 토글
     */
    @Transactional
    public boolean toggleLike(Long commentId, Long memberId) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        // 삭제된 댓글은 좋아요 불가
        if (comment.getIsDeleted()) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }

        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.ENTITY_NOT_FOUND));

        boolean exists = commentLikeRepository.existsByMemberIdAndCommentId(memberId, commentId);

        if (exists) {
            // 좋아요 취소
            commentLikeRepository.findByMemberIdAndCommentId(memberId, commentId)
                    .ifPresent(commentLikeRepository::delete);
            comment.decrementLikeCount();
            return false;
        } else {
            // 좋아요 추가
            CommentLike like = CommentLike.of(member, comment);
            commentLikeRepository.save(like);
            comment.incrementLikeCount();
            return true;
        }
    }

    /**
     * 추천 Top3 댓글 조회 (F16: AC-F6-6)
     */
    public List<CommentResponse> getTopComments(Long postId, Long currentMemberId) {
        List<Comment> topComments = commentRepository.findTopCommentsByFeedPostId(postId);

        // 최대 3개만
        List<Comment> top3 = topComments.stream().limit(3).toList();

        // 좋아요 여부 조회
        List<Long> commentIds = top3.stream().map(Comment::getId).toList();
        Set<Long> likedIds = getLikedCommentIds(commentIds, currentMemberId);

        return top3.stream()
                .map(c -> CommentResponse.from(c, likedIds.contains(c.getId()), List.of()))
                .toList();
    }

    /**
     * 여러 댓글에 대한 좋아요 여부 조회 (N+1 방지)
     */
    private Set<Long> getLikedCommentIds(List<Long> commentIds, Long memberId) {
        if (memberId == null || commentIds.isEmpty()) {
            return Set.of();
        }

        return commentLikeRepository
                .findLikedCommentIdsByMemberIdAndCommentIds(memberId, commentIds)
                .stream()
                .collect(Collectors.toSet());
    }
}
