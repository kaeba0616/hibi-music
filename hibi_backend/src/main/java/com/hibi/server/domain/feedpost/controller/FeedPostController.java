package com.hibi.server.domain.feedpost.controller;

import com.hibi.server.domain.auth.dto.CustomUserDetails;
import com.hibi.server.domain.feedpost.dto.request.FeedPostCreateRequest;
import com.hibi.server.domain.feedpost.dto.request.FeedPostUpdateRequest;
import com.hibi.server.domain.feedpost.dto.response.FeedPostListResponse;
import com.hibi.server.domain.feedpost.dto.response.FeedPostResponse;
import com.hibi.server.domain.feedpost.service.FeedPostService;
import com.hibi.server.domain.follow.service.FollowService;
import com.hibi.server.global.annotation.AuthMember;
import com.hibi.server.global.response.SuccessResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/posts")
@RequiredArgsConstructor
@Tag(name = "Feed Post", description = "피드 게시글 API")
public class FeedPostController {

    private final FeedPostService feedPostService;
    private final FollowService followService;

    @GetMapping
    @Operation(summary = "게시글 목록 조회", description = "피드 게시글 목록을 페이징하여 조회합니다.")
    public ResponseEntity<SuccessResponse<FeedPostListResponse>> getPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthMember CustomUserDetails userDetails
    ) {
        Long memberId = userDetails != null ? userDetails.getId() : null;
        FeedPostListResponse response = feedPostService.getPosts(page, size, memberId);
        return ResponseEntity.ok(SuccessResponse.success("게시글 목록 조회 성공", response));
    }

    @GetMapping("/{postId}")
    @Operation(summary = "게시글 상세 조회", description = "게시글 ID로 상세 정보를 조회합니다.")
    public ResponseEntity<SuccessResponse<FeedPostResponse>> getPost(
            @PathVariable Long postId,
            @AuthMember CustomUserDetails userDetails
    ) {
        Long memberId = userDetails != null ? userDetails.getId() : null;
        FeedPostResponse response = feedPostService.getPost(postId, memberId);
        return ResponseEntity.ok(SuccessResponse.success("게시글 조회 성공", response));
    }

    @PostMapping
    @Operation(summary = "게시글 작성", description = "새로운 피드 게시글을 작성합니다.")
    public ResponseEntity<SuccessResponse<FeedPostResponse>> createPost(
            @RequestBody @Valid FeedPostCreateRequest request,
            @AuthMember CustomUserDetails userDetails
    ) {
        FeedPostResponse response = feedPostService.createPost(request, userDetails.getId());
        return ResponseEntity.ok(SuccessResponse.success("게시글 작성 성공", response));
    }

    @PutMapping("/{postId}")
    @Operation(summary = "게시글 수정", description = "게시글을 수정합니다. 본인 게시글만 수정 가능합니다.")
    public ResponseEntity<SuccessResponse<FeedPostResponse>> updatePost(
            @PathVariable Long postId,
            @RequestBody @Valid FeedPostUpdateRequest request,
            @AuthMember CustomUserDetails userDetails
    ) {
        FeedPostResponse response = feedPostService.updatePost(postId, request, userDetails.getId());
        return ResponseEntity.ok(SuccessResponse.success("게시글 수정 성공", response));
    }

    @DeleteMapping("/{postId}")
    @Operation(summary = "게시글 삭제", description = "게시글을 삭제합니다. 본인 게시글만 삭제 가능합니다.")
    public ResponseEntity<SuccessResponse<?>> deletePost(
            @PathVariable Long postId,
            @AuthMember CustomUserDetails userDetails
    ) {
        feedPostService.deletePost(postId, userDetails.getId());
        return ResponseEntity.ok(SuccessResponse.success("게시글 삭제 성공"));
    }

    @PostMapping("/{postId}/like")
    @Operation(summary = "좋아요 토글", description = "게시글 좋아요를 토글합니다. 이미 좋아요했으면 취소, 아니면 좋아요 추가.")
    public ResponseEntity<SuccessResponse<Boolean>> toggleLike(
            @PathVariable Long postId,
            @AuthMember CustomUserDetails userDetails
    ) {
        boolean isLiked = feedPostService.toggleLike(postId, userDetails.getId());
        String message = isLiked ? "좋아요 추가 성공" : "좋아요 취소 성공";
        return ResponseEntity.ok(SuccessResponse.success(message, isLiked));
    }

    @GetMapping("/following")
    @Operation(summary = "팔로잉 피드 조회", description = "팔로우하는 사용자들의 게시글 목록을 조회합니다.")
    public ResponseEntity<SuccessResponse<FeedPostListResponse>> getFollowingFeed(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthMember CustomUserDetails userDetails
    ) {
        Long memberId = userDetails.getId();
        List<Long> followingIds = followService.getFollowingIds(memberId);
        FeedPostListResponse response = feedPostService.getFollowingFeed(followingIds, page, size, memberId);
        return ResponseEntity.ok(SuccessResponse.success("팔로잉 피드 조회 성공", response));
    }
}
