package com.hibi.server.domain.comment.controller;

import com.hibi.server.domain.auth.dto.CustomUserDetails;
import com.hibi.server.domain.comment.dto.request.CommentCreateRequest;
import com.hibi.server.domain.comment.dto.response.CommentListResponse;
import com.hibi.server.domain.comment.dto.response.CommentResponse;

import java.util.List;
import com.hibi.server.domain.comment.service.CommentService;
import com.hibi.server.global.annotation.AuthMember;
import com.hibi.server.global.response.SuccessResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/posts/{postId}/comments")
@RequiredArgsConstructor
@Tag(name = "Comment", description = "댓글 API")
public class CommentController {

    private final CommentService commentService;

    @GetMapping
    @Operation(summary = "댓글 목록 조회", description = "게시글의 댓글 목록을 조회합니다. 대댓글 포함.")
    public ResponseEntity<SuccessResponse<CommentListResponse>> getComments(
            @PathVariable Long postId,
            @AuthMember CustomUserDetails userDetails
    ) {
        Long memberId = userDetails != null ? userDetails.getId() : null;
        CommentListResponse response = commentService.getComments(postId, memberId);
        return ResponseEntity.ok(SuccessResponse.success("댓글 목록 조회 성공", response));
    }

    @PostMapping
    @Operation(summary = "댓글 작성", description = "게시글에 댓글을 작성합니다. parentId를 지정하면 대댓글이 됩니다.")
    public ResponseEntity<SuccessResponse<CommentResponse>> createComment(
            @PathVariable Long postId,
            @RequestBody @Valid CommentCreateRequest request,
            @AuthMember CustomUserDetails userDetails
    ) {
        CommentResponse response = commentService.createComment(postId, request, userDetails.getId());
        return ResponseEntity.ok(SuccessResponse.success("댓글 작성 성공", response));
    }

    @DeleteMapping("/{commentId}")
    @Operation(summary = "댓글 삭제", description = "댓글을 삭제합니다. 본인 댓글만 삭제 가능. 대댓글이 있으면 soft delete.")
    public ResponseEntity<SuccessResponse<?>> deleteComment(
            @PathVariable Long postId,
            @PathVariable Long commentId,
            @AuthMember CustomUserDetails userDetails
    ) {
        commentService.deleteComment(commentId, userDetails.getId());
        return ResponseEntity.ok(SuccessResponse.success("댓글 삭제 성공"));
    }

    @GetMapping("/top")
    @Operation(summary = "추천 Top3 댓글 조회", description = "좋아요 수 기준 상위 3개 댓글을 조회합니다. (F16: AC-F6-6)")
    public ResponseEntity<SuccessResponse<List<CommentResponse>>> getTopComments(
            @PathVariable Long postId,
            @AuthMember CustomUserDetails userDetails
    ) {
        Long memberId = userDetails != null ? userDetails.getId() : null;
        List<CommentResponse> response = commentService.getTopComments(postId, memberId);
        return ResponseEntity.ok(SuccessResponse.success("추천 댓글 조회 성공", response));
    }

    @PostMapping("/{commentId}/like")
    @Operation(summary = "댓글 좋아요 토글", description = "댓글 좋아요를 토글합니다. 이미 좋아요했으면 취소, 아니면 좋아요 추가.")
    public ResponseEntity<SuccessResponse<Boolean>> toggleLike(
            @PathVariable Long postId,
            @PathVariable Long commentId,
            @AuthMember CustomUserDetails userDetails
    ) {
        boolean isLiked = commentService.toggleLike(commentId, userDetails.getId());
        String message = isLiked ? "좋아요 추가 성공" : "좋아요 취소 성공";
        return ResponseEntity.ok(SuccessResponse.success(message, isLiked));
    }
}
