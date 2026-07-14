package com.hibi.server.domain.auth.service;

import com.hibi.server.domain.auth.client.GoogleUserInfoClient;
import com.hibi.server.domain.auth.client.SocialUserInfo;
import com.hibi.server.domain.auth.dto.CustomUserDetails;
import com.hibi.server.domain.auth.dto.request.SocialLoginRequest;
import com.hibi.server.domain.auth.dto.response.SocialLoginResponse;
import com.hibi.server.domain.auth.jwt.JwtUtils;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
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
    private final GoogleUserInfoClient googleUserInfoClient;

    /**
     * Mock 인증 경로는 명시적으로 켠 환경(로컬/테스트)에서만 허용한다.
     * 기본값 false: 운영에서 임의 문자열로 계정이 발급되는 것을 차단.
     */
    @Value("${auth.social.mock-enabled:false}")
    private boolean socialMockEnabled;

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
     * - GOOGLE: userinfo API로 액세스 토큰을 검증하고 사용자 정보 조회 (실연동)
     * - KAKAO/NAVER: TODO 실제 연동 (kapi.kakao.com/v2/user/me, openapi.naver.com/v1/nid/me)
     * - Mock 모드가 켜져 있으면 모든 제공자에 대해 Mock 경로 사용 (로컬/테스트 전용)
     */
    private SocialUserInfo fetchSocialUserInfo(ProviderType provider, String accessToken) {
        if (socialMockEnabled) {
            log.warn("소셜 사용자 정보 조회 - Mock 모드 (provider: {})", provider);
            return new SocialUserInfo(
                    "social_" + accessToken.hashCode() + "@" + provider.name().toLowerCase() + ".mock",
                    String.valueOf(accessToken.hashCode()),
                    null
            );
        }

        return switch (provider) {
            case GOOGLE -> googleUserInfoClient.fetch(accessToken);
            default -> throw new CustomException(ErrorCode.SOCIAL_LOGIN_NOT_AVAILABLE);
        };
    }

    private String generateDefaultNickname() {
        return "user_" + UUID.randomUUID().toString().substring(0, 8);
    }
}
