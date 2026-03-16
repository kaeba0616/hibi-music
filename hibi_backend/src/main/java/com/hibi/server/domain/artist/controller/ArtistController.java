package com.hibi.server.domain.artist.controller;

import com.hibi.server.domain.artist.dto.request.ArtistCreateRequest;
import com.hibi.server.domain.artist.dto.request.ArtistUpdateRequest;
import com.hibi.server.domain.artist.dto.response.ArtistDetailResponse;
import com.hibi.server.domain.artist.dto.response.ArtistPageResponse;
import com.hibi.server.domain.artist.dto.response.ArtistResponse;
import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.artist.service.ArtistService;
import com.hibi.server.domain.artistfollow.service.ArtistFollowService;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.global.annotation.AuthMember;
import com.hibi.server.global.response.SuccessResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/artists")
@RequiredArgsConstructor
@Tag(name = "Artist", description = "아티스트 API")
public class ArtistController {

    private final ArtistService artistService;
    private final ArtistFollowService artistFollowService;

    /**
     * 아티스트 목록 조회 (AC-F3-1, AC-F3-4)
     */
    @GetMapping
    @Operation(
            summary = "아티스트 목록 조회",
            description = "아티스트 목록을 페이지네이션으로 조회합니다. 팔로우 필터와 검색을 지원합니다."
    )
    public ResponseEntity<SuccessResponse<ArtistPageResponse>> getArtistList(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Boolean following,
            @RequestParam(required = false) String search,
            @AuthMember Member member
    ) {
        Long memberId = member != null ? member.getId() : null;
        Pageable pageable = PageRequest.of(page, size);

        ArtistPageResponse response = artistService.getArtistList(memberId, following, search, pageable);
        return ResponseEntity.ok(SuccessResponse.success("아티스트 목록 조회 성공", response));
    }

    /**
     * 아티스트 상세 조회 (AC-F3-2)
     */
    @GetMapping("/{id}")
    @Operation(
            summary = "아티스트 상세 조회",
            description = "아티스트 ID로 상세 정보를 조회합니다. 프로필, 소개, 노래 목록을 포함합니다."
    )
    public ResponseEntity<SuccessResponse<ArtistDetailResponse>> getArtistDetail(
            @PathVariable Long id,
            @AuthMember Member member
    ) {
        Long memberId = member != null ? member.getId() : null;
        ArtistDetailResponse response = artistService.getArtistDetail(id, memberId);
        return ResponseEntity.ok(SuccessResponse.success("아티스트 조회 성공", response));
    }

    /**
     * 아티스트 팔로우 (AC-F3-3)
     */
    @PostMapping("/{id}/follow")
    @Operation(
            summary = "아티스트 팔로우",
            description = "아티스트를 팔로우합니다. 로그인이 필요합니다."
    )
    public ResponseEntity<SuccessResponse<?>> follow(
            @PathVariable Long id,
            @AuthMember Member member
    ) {
        if (member == null) {
            return ResponseEntity.status(401)
                    .body(SuccessResponse.success("로그인이 필요합니다"));
        }

        artistFollowService.follow(member.getId(), id);
        return ResponseEntity.ok(SuccessResponse.success("팔로우 성공"));
    }

    /**
     * 아티스트 언팔로우 (AC-F3-3)
     */
    @DeleteMapping("/{id}/follow")
    @Operation(
            summary = "아티스트 언팔로우",
            description = "아티스트 팔로우를 취소합니다. 로그인이 필요합니다."
    )
    public ResponseEntity<SuccessResponse<?>> unfollow(
            @PathVariable Long id,
            @AuthMember Member member
    ) {
        if (member == null) {
            return ResponseEntity.status(401)
                    .body(SuccessResponse.success("로그인이 필요합니다"));
        }

        artistFollowService.unfollow(member.getId(), id);
        return ResponseEntity.ok(SuccessResponse.success("언팔로우 성공"));
    }

    // ========== 관리자 API (기존) ==========

    @Operation(summary = "아티스트 생성 (관리자)", description = "새로운 아티스트를 생성합니다.")
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SuccessResponse<?>> create(@RequestBody ArtistCreateRequest request) {
        artistService.create(request);
        return ResponseEntity.ok(SuccessResponse.success("아티스트가 생성되었습니다."));
    }

    @Operation(summary = "아티스트 수정 (관리자)", description = "ID로 기존 아티스트 정보를 수정합니다.")
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SuccessResponse<ArtistResponse>> update(
            @PathVariable Long id,
            @RequestBody @Valid ArtistUpdateRequest request
    ) {
        ArtistResponse updatedArtist = artistService.update(id, request);
        return ResponseEntity.ok(SuccessResponse.success("아티스트가 수정되었습니다.", updatedArtist));
    }

    @Operation(summary = "아티스트 삭제 (관리자)", description = "ID를 통해 아티스트를 삭제합니다.")
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SuccessResponse<?>> delete(@PathVariable Long id) {
        artistService.delete(id);
        return ResponseEntity.ok(SuccessResponse.success("아티스트가 삭제되었습니다."));
    }

    @Operation(summary = "아티스트 전체 조회 (관리자)", description = "등록된 모든 아티스트 목록을 조회합니다.")
    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SuccessResponse<List<ArtistResponse>>> getAll() {
        List<ArtistResponse> artists = artistService.getAll();
        return ResponseEntity.ok(SuccessResponse.success("아티스트 목록 조회 성공", artists));
    }
}
