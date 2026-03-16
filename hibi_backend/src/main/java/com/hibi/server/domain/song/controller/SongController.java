package com.hibi.server.domain.song.controller;

import com.hibi.server.domain.song.dto.request.SongCreateRequest;
import com.hibi.server.domain.song.dto.request.SongUpdateRequest;
import com.hibi.server.domain.song.dto.response.SongResponse;
import com.hibi.server.domain.song.service.SongService;
import com.hibi.server.global.response.SuccessResponse;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/songs")
@RequiredArgsConstructor
public class SongController {

    private final SongService songService;

    @PostMapping
    @Operation(
            summary = "노래 생성",
            description = "새로운 노래를 등록합니다. 요청 본문에 제목, 아티스트, 게시일 등 노래 정보를 포함해야 합니다."
    )
    public ResponseEntity<SuccessResponse<?>> createSong(@RequestBody @Valid SongCreateRequest request) {
        songService.create(request);
        return ResponseEntity.ok(SuccessResponse.success("노래 생성 성공"));
    }

    @PutMapping("/{id}")
    @Operation(
            summary = "노래 정보 수정",
            description = "노래 ID를 기반으로 해당 노래의 정보를 수정합니다. 요청 본문에 변경할 내용을 포함해야 합니다."
    )
    public ResponseEntity<SuccessResponse<SongResponse>> updateSong(
            @PathVariable Long id,
            @RequestBody @Valid SongUpdateRequest request
    ) {
        return ResponseEntity.ok(SuccessResponse.success("노래 수정 성공", songService.update(id, request)));
    }

    @DeleteMapping("/{id}")
    @Operation(
            summary = "노래 삭제",
            description = "노래 ID를 기반으로 해당 노래를 삭제합니다."
    )
    public ResponseEntity<SuccessResponse<?>> deleteSong(@PathVariable Long id) {
        return ResponseEntity.ok(SuccessResponse.success("노래 삭제 성공"));
    }

    @GetMapping
    @Operation(
            summary = "모든 노래 조회",
            description = "등록된 모든 노래 목록을 조회합니다."
    )
    public ResponseEntity<SuccessResponse<List<SongResponse>>> getAllSongs() {
        return ResponseEntity.ok(SuccessResponse.success("모든 노래 조회 성공", songService.getAll()));
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "ID로 노래 조회",
            description = "노래 ID를 기반으로 단일 노래 정보를 조회합니다."
    )
    public ResponseEntity<SuccessResponse<SongResponse>> getSongById(@PathVariable Long id) {
        return ResponseEntity.ok(SuccessResponse.success("노래 조회 성공", songService.getById(id)));
    }

    @GetMapping("/by-date")
    @Operation(
            summary = "날짜로 노래 조회",
            description = "입력한 날짜(postedAt)에 등록된 노래 정보를 조회합니다. 날짜는 yyyy-MM-dd 형식입니다."
    )
    public ResponseEntity<SuccessResponse<SongResponse>> getSongByPostedDate(
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        return ResponseEntity.ok(SuccessResponse.success("노래 조회 성공", songService.getByDate(date)));
    }

    @GetMapping("/by-month")
    @Operation(
            summary = "월별 노래 조회",
            description = "입력한 연도와 월에 등록된 노래 목록을 조회합니다. 예: year=2025&month=7"
    )
    public ResponseEntity<SuccessResponse<List<SongResponse>>> getSongsByMonth(
            @RequestParam("month") int month,
            @RequestParam("year") int year
    ) {
        return ResponseEntity.ok(SuccessResponse.success("노래 조회 성공", songService.getByMonth(year, month)));
    }
}
