package com.hibi.server.domain.auth.service;

import com.hibi.server.domain.auth.dto.CustomUserDetails;
import com.hibi.server.domain.auth.dto.request.SocialLoginRequest;
import com.hibi.server.domain.auth.dto.response.SocialLoginResponse;
import com.hibi.server.domain.auth.jwt.JwtUtils;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import com.hibi.server.domain.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SocialAuthService {

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;
    private final RefreshTokenService refreshTokenService;

    /**
     * 소셜 로그인 처리
     *
     * 1. 소셜 제공자로부터 사용자 정보 조회 (provider + accessToken)
     * 2. 기존 회원인지 확인 (email 또는 provider+providerId)
     * 3. 신규 회원이면 자동 가입
     * 4. JWT 토큰 발급
     */
    @Transactional
    public SocialLoginResponse socialLogin(SocialLoginRequest request) {
        ProviderType provider = request.provider();
        String socialAccessToken = request.accessToken();

        // 소셜 제공자에서 사용자 정보 조회
        SocialUserInfo userInfo = fetchSocialUserInfo(provider, socialAccessToken);

        // 기존 회원 조회 (provider + providerId)
        Optional<Member> existingMember = memberRepository.findByProviderAndProviderId(
                provider, userInfo.providerId());

        boolean isNewUser;
        Member member;

        if (existingMember.isPresent()) {
            // 기존 회원: 로그인
            member = existingMember.get();
            isNewUser = false;
            log.info("소셜 로그인 - 기존 회원: {} ({})", member.getEmail(), provider);
        } else {
            // 이메일로도 확인 (다른 방식으로 이미 가입한 경우)
            Optional<Member> emailMember = memberRepository.findByEmail(userInfo.email());
            if (emailMember.isPresent()) {
                // 기존 이메일로 가입된 회원 → provider 연결
                member = emailMember.get();
                isNewUser = false;
                log.info("소셜 로그인 - 기존 이메일 회원에 소셜 연결: {} ({})", member.getEmail(), provider);
            } else {
                // 완전 신규 회원: 자동 가입
                String nickname = request.nickname() != null
                        ? request.nickname()
                        : generateDefaultNickname();

                member = Member.of(
                        userInfo.email(),
                        passwordEncoder.encode(UUID.randomUUID().toString()),
                        nickname,
                        provider,
                        userInfo.providerId(),
                        userInfo.profileUrl(),
                        UserRoleType.USER
                );
                memberRepository.save(member);
                isNewUser = true;
                log.info("소셜 로그인 - 신규 회원 가입: {} ({})", member.getEmail(), provider);
            }
        }

        // JWT 토큰 발급
        CustomUserDetails userDetails = new CustomUserDetails(member);
        Authentication authentication = new UsernamePasswordAuthenticationToken(
                userDetails, null,
                List.of(new SimpleGrantedAuthority("ROLE_" + member.getRole().name()))
        );

        String accessToken = jwtUtils.generateAccessToken(authentication);
        String refreshToken = refreshTokenService.createAndSaveRefreshToken(
                member.getId(), authentication);

        return SocialLoginResponse.of(
                accessToken, refreshToken, member.getId(), member.getRole(), isNewUser);
    }

    /**
     * 소셜 제공자에서 사용자 정보 조회
     *
     * TODO: 실제 소셜 API 연동 시 구현
     * - 카카오: https://kapi.kakao.com/v2/user/me
     * - 구글: https://www.googleapis.com/oauth2/v3/userinfo
     * - 네이버: https://openapi.naver.com/v1/nid/me
     */
    private SocialUserInfo fetchSocialUserInfo(ProviderType provider, String accessToken) {
        // TODO: 실제 소셜 API 호출로 대체
        // 현재는 accessToken을 providerId로 사용하는 Mock 구현
        log.warn("소셜 사용자 정보 조회 - Mock 모드 (provider: {})", provider);

        return new SocialUserInfo(
                "social_" + accessToken.hashCode() + "@" + provider.name().toLowerCase() + ".mock",
                String.valueOf(accessToken.hashCode()),
                null
        );
    }

    private String generateDefaultNickname() {
        return "user_" + UUID.randomUUID().toString().substring(0, 8);
    }

    /**
     * 소셜 제공자로부터 받아오는 사용자 정보
     */
    private record SocialUserInfo(
            String email,
            String providerId,
            String profileUrl
    ) {}
}
