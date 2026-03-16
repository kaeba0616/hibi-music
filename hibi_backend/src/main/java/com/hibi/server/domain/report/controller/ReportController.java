package com.hibi.server.domain.report.controller;

import com.hibi.server.domain.auth.dto.CustomUserDetails;
import com.hibi.server.domain.report.dto.request.ReportCreateRequest;
import com.hibi.server.domain.report.dto.response.ReportCheckResponse;
import com.hibi.server.domain.report.dto.response.ReportResponse;
import com.hibi.server.domain.report.service.ReportService;
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
 * 신고 Controller (F11)
 */
@RestController
@RequestMapping("/api/v1/reports")
@RequiredArgsConstructor
@Tag(name = "Report", description = "신고 API")
public class ReportController {

    private final ReportService reportService;

    @PostMapping
    @Operation(
            summary = "신고 생성",
            description = "게시글, 댓글, 사용자를 신고합니다. 로그인이 필요합니다."
    )
    public ResponseEntity<SuccessResponse<ReportResponse>> createReport(
            @RequestBody @Valid ReportCreateRequest request,
            @AuthMember CustomUserDetails userDetails
    ) {
        ReportResponse response = reportService.createReport(request, userDetails.getId());
        return ResponseEntity.ok(SuccessResponse.success("신고가 접수되었습니다", response));
    }

    @GetMapping("/check")
    @Operation(
            summary = "중복 신고 여부 확인",
            description = "해당 대상에 대해 이미 신고했는지 확인합니다."
    )
    public ResponseEntity<SuccessResponse<ReportCheckResponse>> checkAlreadyReported(
            @Parameter(description = "신고 대상 유형", example = "POST")
            @RequestParam String targetType,
            @Parameter(description = "신고 대상 ID", example = "42")
            @RequestParam Long targetId,
            @AuthMember CustomUserDetails userDetails
    ) {
        ReportCheckResponse response = reportService.checkAlreadyReported(
                userDetails.getId(),
                targetType,
                targetId
        );
        return ResponseEntity.ok(SuccessResponse.success("조회 성공", response));
    }
}
