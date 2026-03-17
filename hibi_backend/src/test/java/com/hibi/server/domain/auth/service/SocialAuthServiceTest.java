package com.hibi.server.domain.auth.service;

import com.hibi.server.domain.auth.dto.request.SocialLoginRequest;
import com.hibi.server.domain.auth.dto.response.SocialLoginResponse;
import com.hibi.server.domain.auth.jwt.JwtUtils;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.MemberStatus;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.support.ServiceTestSupport;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;

@DisplayName("SocialAuthService 단위 테스트")
class SocialAuthServiceTest extends ServiceTestSupport {

    @Mock
    private MemberRepository memberRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtUtils jwtUtils;

    @Mock
    private RefreshTokenService refreshTokenService;

    @InjectMocks
    private SocialAuthService socialAuthService;

    private Member createTestMember(Long id, ProviderType provider) {
        return Member.builder()
                .id(id)
                .email("user@example.com")
                .password("encodedPassword")
                .nickname("테스트유저")
                .provider(provider)
                .providerId("social123")
                .role(UserRoleType.USER)
                .status(MemberStatus.ACTIVE)
                .build();
    }

    @Nested
    @DisplayName("socialLogin 메서드")
    class SocialLoginTest {

        @Test
        @DisplayName("기존 소셜 회원이면 로그인에 성공한다")
        void socialLogin_기존회원_성공() {
            // given
            SocialLoginRequest request = new SocialLoginRequest(ProviderType.KAKAO, "test-access-token", null);
            Member existingMember = createTestMember(1L, ProviderType.KAKAO);

            given(memberRepository.findByProviderAndProviderId(eq(ProviderType.KAKAO), anyString()))
                    .willReturn(Optional.of(existingMember));
            given(jwtUtils.generateAccessToken(any(Authentication.class))).willReturn("access-token");
            given(refreshTokenService.createAndSaveRefreshToken(eq(1L), any(Authentication.class)))
                    .willReturn("refresh-token");

            // when
            SocialLoginResponse response = socialAuthService.socialLogin(request);

            // then
            assertThat(response).isNotNull();
            assertThat(response.accessToken()).isEqualTo("access-token");
            assertThat(response.refreshToken()).isEqualTo("refresh-token");
            assertThat(response.memberId()).isEqualTo(1L);
            assertThat(response.isNewUser()).isFalse();
            then(memberRepository).should(never()).save(any(Member.class));
        }

        @Test
        @DisplayName("신규 소셜 회원이면 자동 가입 후 로그인에 성공한다")
        void socialLogin_신규회원_자동가입_성공() {
            // given
            SocialLoginRequest request = new SocialLoginRequest(ProviderType.GOOGLE, "new-access-token", "새유저");

            given(memberRepository.findByProviderAndProviderId(eq(ProviderType.GOOGLE), anyString()))
                    .willReturn(Optional.empty());
            given(memberRepository.findByEmail(anyString()))
                    .willReturn(Optional.empty());
            given(passwordEncoder.encode(anyString())).willReturn("encodedRandomPassword");

            Member savedMember = Member.builder()
                    .id(2L)
                    .email("social@google.mock")
                    .password("encodedRandomPassword")
                    .nickname("새유저")
                    .provider(ProviderType.GOOGLE)
                    .role(UserRoleType.USER)
                    .status(MemberStatus.ACTIVE)
                    .build();
            given(memberRepository.save(any(Member.class))).willReturn(savedMember);
            given(jwtUtils.generateAccessToken(any(Authentication.class))).willReturn("access-token");
            given(refreshTokenService.createAndSaveRefreshToken(any(), any(Authentication.class)))
                    .willReturn("refresh-token");

            // when
            SocialLoginResponse response = socialAuthService.socialLogin(request);

            // then
            assertThat(response).isNotNull();
            assertThat(response.isNewUser()).isTrue();
            then(memberRepository).should(times(1)).save(any(Member.class));
        }

        @Test
        @DisplayName("기존 이메일 회원에 소셜 계정을 연결한다")
        void socialLogin_기존이메일회원_소셜연결() {
            // given
            SocialLoginRequest request = new SocialLoginRequest(ProviderType.NAVER, "naver-access-token", null);
            Member emailMember = Member.builder()
                    .id(3L)
                    .email("social@naver.mock")
                    .password("encodedPassword")
                    .nickname("네이티브유저")
                    .provider(ProviderType.NATIVE)
                    .role(UserRoleType.USER)
                    .status(MemberStatus.ACTIVE)
                    .build();

            given(memberRepository.findByProviderAndProviderId(eq(ProviderType.NAVER), anyString()))
                    .willReturn(Optional.empty());
            given(memberRepository.findByEmail(anyString()))
                    .willReturn(Optional.of(emailMember));
            given(jwtUtils.generateAccessToken(any(Authentication.class))).willReturn("access-token");
            given(refreshTokenService.createAndSaveRefreshToken(eq(3L), any(Authentication.class)))
                    .willReturn("refresh-token");

            // when
            SocialLoginResponse response = socialAuthService.socialLogin(request);

            // then
            assertThat(response).isNotNull();
            assertThat(response.memberId()).isEqualTo(3L);
            assertThat(response.isNewUser()).isFalse();
            then(memberRepository).should(never()).save(any(Member.class));
        }
    }
}
