package com.hibi.server.domain.auth.service;

import com.hibi.server.domain.auth.dto.CustomUserDetails;
import com.hibi.server.domain.auth.dto.request.SignInRequest;
import com.hibi.server.domain.auth.dto.request.SignUpRequest;
import com.hibi.server.domain.auth.dto.response.SignInResponse;
import com.hibi.server.domain.auth.jwt.JwtUtils;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.member.validator.MemberValidator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;
    private final RefreshTokenService refreshTokenService;
    private final MemberValidator memberValidator;

    @Transactional
    public void signUp(SignUpRequest request) {
        String email = request.email();
        String password = request.password();
        String nickname = request.nickname();

        memberValidator.validateEmail(email);
        memberValidator.validatePassword(password);
        memberValidator.validateNickname(nickname, null); // 신규 가입: 이전 닉네임 없음
        Optional<Member> deleted = memberRepository.findByEmailAndDeletedAtIsNotNull(email);

        if (deleted.isPresent()) {
            Member member = deleted.get();
            member.reactivateAccount(passwordEncoder.encode(password), nickname);
        } else {
            Member member = Member.of(
                    email,
                    passwordEncoder.encode(password),
                    nickname,
                    ProviderType.NATIVE,
                    null,
                    null,
                    UserRoleType.USER
            );
            memberRepository.save(member);
        }
    }

    @Transactional
    public SignInResponse signIn(SignInRequest request) {

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password()));
        CustomUserDetails customUserDetails = (CustomUserDetails) authentication.getPrincipal();
        long memberId = customUserDetails.getId();
        String accessToken = jwtUtils.generateAccessToken(authentication);
        String refreshToken = refreshTokenService.createAndSaveRefreshToken(memberId, authentication);

        return SignInResponse.of(accessToken, refreshToken, memberId, customUserDetails.getRole());
    }

    @Transactional
    public void signOut(Long memberId) {
        refreshTokenService.invalidateAllRefreshTokensForMember(memberId);
    }

    public void checkEmailAvailability(String email) {
        memberValidator.validateEmail(email);
    }

    public void checkNicknameAvailability(String nickname) {
        memberValidator.validateNickname(nickname, null);
    }
}