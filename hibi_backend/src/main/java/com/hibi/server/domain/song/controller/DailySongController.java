package com.hibi.server.domain.song.controller;

import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.song.dto.response.DailySongResponse;
import com.hibi.server.domain.song.service.DailySongService;
import com.hibi.server.global.annotation.AuthMember;
import com.hibi.server.global.response.SuccessResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/daily-songs")
@RequiredArgsConstructor
@Tag(name = "Daily Song", description = "오늘의 노래 API")
public class DailySongController {

    private final DailySongService dailySongService;

    @GetMapping("/today")
    @Operation(
            summary = "오늘의 노래 조회",
            description = "오늘 추천된 노래를 조회합니다. 추천곡이 없으면 data가 null입니다."
    )
    public ResponseEntity<SuccessResponse<DailySongResponse>> getTodaySong(
            @AuthMember Member member
    ) {
        Long memberId = member != null ? member.getId() : null;
        return dailySongService.getTodaySong(memberId)
                .map(song -> ResponseEntity.ok(SuccessResponse.success("오늘의 노래 조회 성공", song)))
                .orElse(ResponseEntity.ok(SuccessResponse.success("오늘의 추천곡이 없습니다", null)));
    }

    @GetMapping("/by-date")
    @Operation(
            summary = "날짜별 노래 조회",
            description = "특정 날짜에 추천된 노래를 조회합니다. 형식: yyyy-MM-dd"
    )
    public ResponseEntity<SuccessResponse<DailySongResponse>> getSongByDate(
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @AuthMember Member member
    ) {
        Long memberId = member != null ? member.getId() : null;
        return dailySongService.getSongByDate(date, memberId)
                .map(song -> ResponseEntity.ok(SuccessResponse.success("노래 조회 성공", song)))
                .orElse(ResponseEntity.ok(SuccessResponse.success("해당 날짜의 추천곡이 없습니다", null)));
    }

    @GetMapping("/{songId}")
    @Operation(
            summary = "노래 상세 조회",
            description = "노래 ID로 상세 정보를 조회합니다."
    )
    public ResponseEntity<SuccessResponse<DailySongResponse>> getSongById(
            @PathVariable Long songId,
            @AuthMember Member member
    ) {
        Long memberId = member != null ? member.getId() : null;
        DailySongResponse response = dailySongService.getSongById(songId, memberId);
        return ResponseEntity.ok(SuccessResponse.success("노래 조회 성공", response));
    }

    @GetMapping("/by-month")
    @Operation(
            summary = "월별 노래 목록 조회",
            description = "특정 연도/월에 추천된 노래 목록을 조회합니다."
    )
    public ResponseEntity<SuccessResponse<List<DailySongResponse>>> getSongsByMonth(
            @RequestParam("year") int year,
            @RequestParam("month") int month,
            @AuthMember Member member
    ) {
        Long memberId = member != null ? member.getId() : null;
        List<DailySongResponse> songs = dailySongService.getSongsByMonth(year, month, memberId);
        return ResponseEntity.ok(SuccessResponse.success("월별 노래 조회 성공", songs));
    }

    @PostMapping("/{songId}/like")
    @Operation(
            summary = "좋아요 토글",
            description = "노래에 좋아요를 추가하거나 취소합니다."
    )
    public ResponseEntity<SuccessResponse<LikeToggleResponse>> toggleLike(
            @PathVariable Long songId,
            @AuthMember Member member
    ) {
        if (member == null) {
            return ResponseEntity.status(401)
                    .body(SuccessResponse.success("로그인이 필요합니다", null));
        }

        boolean isLiked = dailySongService.toggleLike(member.getId(), songId);
        String message = isLiked ? "좋아요 추가" : "좋아요 취소";
        return ResponseEntity.ok(SuccessResponse.success(message, new LikeToggleResponse(isLiked)));
    }

    /**
     * 좋아요 토글 응답
     */
    public record LikeToggleResponse(boolean isLiked) {}
}
