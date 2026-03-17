package com.hibi.server.domain.question.controller;

import com.hibi.server.domain.auth.dto.CustomUserDetails;
import com.hibi.server.domain.question.dto.request.QuestionCreateRequest;
import com.hibi.server.domain.question.dto.response.QuestionListResponse;
import com.hibi.server.domain.question.dto.response.QuestionResponse;
import com.hibi.server.domain.question.service.QuestionService;
import com.hibi.server.global.annotation.AuthMember;
import com.hibi.server.global.response.SuccessResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * 문의 Controller (F10)
 */
@RestController
@RequestMapping("/api/v1/questions")
@RequiredArgsConstructor
@Tag(name = "Question", description = "문의하기 API")
public class QuestionController {

    private final QuestionService questionService;

    @GetMapping
    @Operation(
            summary = "문의 목록 조회",
            description = "로그인한 사용자의 문의 목록을 조회합니다."
    )
    public ResponseEntity<SuccessResponse<QuestionListResponse>> getMyQuestions(
            @AuthMember CustomUserDetails userDetails
    ) {
        QuestionListResponse response = questionService.getMyQuestions(userDetails.getId());

        String message = response.totalCount() > 0
                ? "문의 목록 조회 성공"
                : "문의 내역이 없습니다";

        return ResponseEntity.ok(SuccessResponse.success(message, response));
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "문의 상세 조회",
            description = "특정 문의의 상세 정보를 조회합니다. 본인 문의만 조회 가능합니다."
    )
    public ResponseEntity<SuccessResponse<QuestionResponse>> getQuestionById(
            @Parameter(description = "문의 ID", required = true)
            @PathVariable Long id,
            @AuthMember CustomUserDetails userDetails
    ) {
        QuestionResponse response = questionService.getQuestionById(id, userDetails.getId());
        return ResponseEntity.ok(SuccessResponse.success("문의 조회 성공", response));
    }

    @GetMapping("/today-count")
    @Operation(
            summary = "오늘 문의 작성 수 조회 (F17)",
            description = "로그인한 사용자가 오늘 작성한 문의 수를 반환합니다."
    )
    public ResponseEntity<SuccessResponse<Long>> getTodayQuestionCount(
            @AuthMember CustomUserDetails userDetails
    ) {
        long count = questionService.getTodayQuestionCount(userDetails.getId());
        return ResponseEntity.ok(SuccessResponse.success("오늘 문의 작성 수 조회 성공", count));
    }

    @PostMapping
    @Operation(
            summary = "문의 작성",
            description = "새로운 문의를 작성합니다. 로그인이 필요합니다."
    )
    public ResponseEntity<SuccessResponse<QuestionResponse>> createQuestion(
            @RequestBody @Valid QuestionCreateRequest request,
            @AuthMember CustomUserDetails userDetails
    ) {
        QuestionResponse response = questionService.createQuestion(request, userDetails.getId());
        return ResponseEntity.ok(SuccessResponse.success("문의가 접수되었습니다", response));
    }
}
