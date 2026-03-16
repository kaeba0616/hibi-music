package com.hibi.server.domain.follow.controller;

import com.hibi.server.domain.auth.dto.CustomUserDetails;
import com.hibi.server.domain.feedpost.dto.response.FeedPostListResponse;
import com.hibi.server.domain.feedpost.service.FeedPostService;
import com.hibi.server.domain.follow.dto.response.FollowListResponse;
import com.hibi.server.domain.follow.dto.response.UserProfileResponse;
import com.hibi.server.domain.follow.service.FollowService;
import com.hibi.server.global.annotation.AuthMember;
import com.hibi.server.global.response.SuccessResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Tag(name = "Follow", description = "팔로우 API")
public class FollowController {

    private final FollowService followService;
    private final FeedPostService feedPostService;

    @GetMapping("/{userId}")
    @Operation(summary = "사용자 프로필 조회", description = "사용자의 프로필 정보를 조회합니다.")
    public ResponseEntity<SuccessResponse<UserProfileResponse>> getUserProfile(
            @PathVariable Long userId,
            @AuthMember CustomUserDetails userDetails
    ) {
        Long currentUserId = userDetails != null ? userDetails.getId() : null;
        UserProfileResponse response = followService.getUserProfile(userId, currentUserId);
        return ResponseEntity.ok(SuccessResponse.success("프로필 조회 성공", response));
    }

    @GetMapping("/{userId}/followers")
    @Operation(summary = "팔로워 목록 조회", description = "특정 사용자의 팔로워 목록을 조회합니다.")
    public ResponseEntity<SuccessResponse<FollowListResponse>> getFollowers(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthMember CustomUserDetails userDetails
    ) {
        Long currentUserId = userDetails != null ? userDetails.getId() : null;
        FollowListResponse response = followService.getFollowers(userId, currentUserId, page, size);
        return ResponseEntity.ok(SuccessResponse.success("팔로워 목록 조회 성공", response));
    }

    @GetMapping("/{userId}/followings")
    @Operation(summary = "팔로잉 목록 조회", description = "특정 사용자의 팔로잉 목록을 조회합니다.")
    public ResponseEntity<SuccessResponse<FollowListResponse>> getFollowings(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthMember CustomUserDetails userDetails
    ) {
        Long currentUserId = userDetails != null ? userDetails.getId() : null;
        FollowListResponse response = followService.getFollowings(userId, currentUserId, page, size);
        return ResponseEntity.ok(SuccessResponse.success("팔로잉 목록 조회 성공", response));
    }

    @PostMapping("/{userId}/follow")
    @Operation(summary = "팔로우", description = "특정 사용자를 팔로우합니다.")
    public ResponseEntity<SuccessResponse<?>> follow(
            @PathVariable Long userId,
            @AuthMember CustomUserDetails userDetails
    ) {
        followService.follow(userId, userDetails.getId());
        return ResponseEntity.ok(SuccessResponse.success("팔로우 성공"));
    }

    @DeleteMapping("/{userId}/follow")
    @Operation(summary = "언팔로우", description = "특정 사용자를 언팔로우합니다.")
    public ResponseEntity<SuccessResponse<?>> unfollow(
            @PathVariable Long userId,
            @AuthMember CustomUserDetails userDetails
    ) {
        followService.unfollow(userId, userDetails.getId());
        return ResponseEntity.ok(SuccessResponse.success("언팔로우 성공"));
    }

    @GetMapping("/{userId}/posts")
    @Operation(summary = "사용자 게시글 목록 조회", description = "특정 사용자의 게시글 목록을 조회합니다.")
    public ResponseEntity<SuccessResponse<FeedPostListResponse>> getUserPosts(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthMember CustomUserDetails userDetails
    ) {
        Long currentUserId = userDetails != null ? userDetails.getId() : null;
        FeedPostListResponse response = feedPostService.getUserPosts(userId, page, size, currentUserId);
        return ResponseEntity.ok(SuccessResponse.success("사용자 게시글 목록 조회 성공", response));
    }
}
