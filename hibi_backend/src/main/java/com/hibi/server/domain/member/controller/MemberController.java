package com.hibi.server.domain.member.controller;

import com.hibi.server.domain.auth.dto.CustomUserDetails;
import com.hibi.server.domain.member.dto.request.MemberUpdateRequest;
import com.hibi.server.domain.member.dto.response.MemberProfileResponse;
import com.hibi.server.domain.member.service.MemberService;
import com.hibi.server.global.annotation.AuthMember;
import com.hibi.server.global.response.SuccessResponse;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/members")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    @Operation(
            description = "accessToken을 통해 정보를 조회하므로 빈 JSON 형식({})을 보내면 요청이 갑니다."
    )
    @GetMapping("/me")
    public ResponseEntity<SuccessResponse<MemberProfileResponse>> getMyInfo(@AuthMember CustomUserDetails userDetails) {
        long memberId = userDetails.getId();
        MemberProfileResponse memberProfile = memberService.getMyProfileById(memberId);
        return ResponseEntity.ok(SuccessResponse.success("내 정보 조회에 성공했습니다.", memberProfile));
    }

    @Operation(
            summary = "특정 회원 정보 조회 (오픈된 프로필)",
            description = "특정 memberId를 가진 회원의 프로필 정보를 조회합니다. 관리자 권한이 필요할 수 있습니다."
    )
    @GetMapping("/info/{memberId}")
    public ResponseEntity<SuccessResponse<MemberProfileResponse>> getMemberById(@PathVariable Long memberId) {
        MemberProfileResponse memberProfile = memberService.getMemberProfileById(memberId);
        return ResponseEntity.ok(SuccessResponse.success(memberId + "번 회원 정보 조회 성공", memberProfile));
    }

    @Operation(
            summary = "인증된 회원 정보 부분 수정 (닉네임, 비밀번호 등)",
            description = "현재 로그인된 회원의 닉네임 또는 비밀번호 등 일부 정보를 수정합니다. 요청 본문에 포함된 필드만 변경됩니다."
    )
    @PatchMapping("/me")
    public ResponseEntity<SuccessResponse<MemberProfileResponse>> updateMyPartialInfo(
            @AuthMember CustomUserDetails userDetails,
            @Valid @RequestBody MemberUpdateRequest request) {
        long memberId = userDetails.getId();
        MemberProfileResponse updatedProfile = memberService.updateMemberInfo(memberId, request);
        return ResponseEntity.ok(SuccessResponse.success("내 정보 수정에 성공했습니다.", updatedProfile));
    }

    @Operation(
            summary = "인증된 회원 탈퇴",
            description = "현재 로그인된 회원의 계정을 탈퇴합니다."
    )
    @DeleteMapping("/me")
    public ResponseEntity<SuccessResponse<?>> withdrawMember(@AuthMember CustomUserDetails userDetails) {
        memberService.withdrawMember(userDetails.getId());
        return ResponseEntity.ok(SuccessResponse.success("회원 탈퇴에 성공했습니다."));
    }

    @Operation(
            summary = "모든 회원 정보 조회 (관리자용)",
            description = "모든 회원의 정보를 조회합니다. 관리자 권한이 필요할 수 있습니다."
    )
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SuccessResponse<?>> getAllMembers() {
        List<MemberProfileResponse> allMembers = memberService.getAllMembers();
        return ResponseEntity.ok(SuccessResponse.success("모든 회원 정보 조회 성공", allMembers));
    }


    //TODO : 아이디 찾기
    //TODO : 비밀번호 찾기
    //TODO : OAuth
}