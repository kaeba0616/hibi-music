package com.hibi.server.domain.auth.controller;

import com.hibi.server.domain.auth.dto.request.SignInRequest;
import com.hibi.server.domain.auth.dto.request.SignUpRequest;
import com.hibi.server.domain.auth.dto.request.SocialLoginRequest;
import com.hibi.server.domain.auth.dto.response.ReissueResponse;
import com.hibi.server.domain.auth.dto.response.SignInResponse;
import com.hibi.server.domain.auth.dto.response.SocialLoginResponse;
import com.hibi.server.domain.auth.service.AuthService;
import com.hibi.server.domain.auth.service.RefreshTokenService;
import com.hibi.server.domain.auth.service.SocialAuthService;
import com.hibi.server.domain.member.dto.response.AvailabilityResponse;
import com.hibi.server.domain.member.validator.MemberValidator;
import com.hibi.server.global.response.SuccessResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.function.BiFunction;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Auth", description = "인증 API")
public class AuthController {

    private final AuthService authService;
    private final RefreshTokenService refreshTokenService;
    private final SocialAuthService socialAuthService;
    private final MemberValidator memberValidator;

    @PostMapping("/sign-up")
    public ResponseEntity<SuccessResponse<?>> signup(@Valid @RequestBody SignUpRequest request) {
        authService.signUp(request);
        return ResponseEntity.ok(SuccessResponse.success("회원가입에 성공했습니다."));
    }

    @PostMapping("/sign-in")
    public ResponseEntity<SuccessResponse<SignInResponse>> signIn(@Valid @RequestBody SignInRequest request) {
        return ResponseEntity.ok(SuccessResponse.success("로그인에 성공하였습니다.", authService.signIn(request)));
    }

    @PostMapping("/sign-out")
    public ResponseEntity<SuccessResponse<?>> signOut(@RequestParam Long memberId) {
        authService.signOut(memberId);
        return ResponseEntity.ok(SuccessResponse.success("로그아웃하였습니다."));
    }

    @PostMapping("/reissue")
    public ResponseEntity<SuccessResponse<ReissueResponse>> reissueTokens(@RequestParam String refreshToken) {
        return ResponseEntity.ok(SuccessResponse.success("토큰 재발급에 성공하였습니다.", refreshTokenService.reissueTokens(refreshToken)));
    }

    @Operation(
            summary = "이메일 사용 가능 여부 확인",
            description = "주어진 이메일이 현재 사용 가능한지 확인합니다."
    )
    @GetMapping("/check-email")
    public ResponseEntity<SuccessResponse<?>> checkEmailAvailability(@RequestParam String email) {
        authService.checkEmailAvailability(email);
        return ResponseEntity.ok(SuccessResponse.success(email + "은(는) 사용 가능 합니다."));
    }

    @Operation(
            summary = "닉네임 사용 가능 여부 확인",
            description = "주어진 닉네임이 현재 사용 가능한지 확인합니다."
    )
    @Operation(
            summary = "소셜 로그인",
            description = "카카오/구글/네이버 소셜 로그인을 처리합니다. 신규 회원은 자동 가입됩니다."
    )
    @PostMapping("/social-login")
    public ResponseEntity<SuccessResponse<SocialLoginResponse>> socialLogin(
            @Valid @RequestBody SocialLoginRequest request) {
        return ResponseEntity.ok(
                SuccessResponse.success("소셜 로그인에 성공하였습니다.", socialAuthService.socialLogin(request))
        );
    }

    @GetMapping("/check-nickname")
    public ResponseEntity<SuccessResponse<?>> checkNicknameAvailability(@RequestParam String nickname) {
        memberValidator.validateNickname(nickname, null);
        return ResponseEntity.ok(SuccessResponse.success(nickname + "은(는) 사용 가능 합니다."));

    }
}