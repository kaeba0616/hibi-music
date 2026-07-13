package com.hibi.server.domain.auth.controller;

import com.hibi.server.domain.auth.dto.request.SignInRequest;
import com.hibi.server.domain.auth.dto.request.SignUpRequest;
import com.hibi.server.domain.auth.repository.RefreshTokenRepository;
import com.hibi.server.support.IntegrationTestSupport;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("AuthController 통합 테스트")
class AuthControllerIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    private String signUpAndSignIn(String email, String password, String nickname) throws Exception {
        SignUpRequest signUp = new SignUpRequest(email, password, nickname);
        mockMvc.perform(post("/api/v1/auth/sign-up")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(signUp)));

        SignInRequest signIn = new SignInRequest(email, password);
        MvcResult result = mockMvc.perform(post("/api/v1/auth/sign-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(signIn)))
                .andReturn();
        return objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data").path("accessToken").asText();
    }

    @Nested
    @DisplayName("POST /api/v1/auth/sign-out")
    class SignOutTest {

        @Test
        @DisplayName("미인증 사용자는 로그아웃할 수 없다 (401)")
        void signOut_미인증_실패() throws Exception {
            mockMvc.perform(post("/api/v1/auth/sign-out"))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("인증된 사용자는 본인 세션만 로그아웃되고 리프레시 토큰이 revoke된다")
        void signOut_본인_성공() throws Exception {
            // given
            String accessToken = signUpAndSignIn("signout-test@example.com", "password1", "로그아웃유저");

            // when
            mockMvc.perform(post("/api/v1/auth/sign-out")
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isOk());

            // then: 활성 리프레시 토큰이 남아있지 않아야 한다
            boolean hasActiveToken = refreshTokenRepository.findAll().stream()
                    .filter(token -> token.getMember().getEmail().equals("signout-test@example.com"))
                    .anyMatch(token -> !token.isRevoked());
            assertThat(hasActiveToken).isFalse();
        }
    }

    @Nested
    @DisplayName("POST /api/v1/auth/reissue")
    class ReissueTest {

        @Test
        @DisplayName("JSON 본문의 리프레시 토큰으로 재발급에 성공한다")
        void reissue_JSON본문_성공() throws Exception {
            // given
            SignUpRequest signUp = new SignUpRequest("reissue-test@example.com", "password1", "재발급유저");
            mockMvc.perform(post("/api/v1/auth/sign-up")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(signUp)));

            SignInRequest signIn = new SignInRequest("reissue-test@example.com", "password1");
            MvcResult signInResult = mockMvc.perform(post("/api/v1/auth/sign-in")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(signIn)))
                    .andReturn();
            String refreshToken = objectMapper.readTree(signInResult.getResponse().getContentAsString())
                    .path("data").path("refreshToken").asText();

            // when & then
            mockMvc.perform(post("/api/v1/auth/reissue")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"refreshToken\": \"" + refreshToken + "\"}"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data.accessToken").exists())
                    .andExpect(jsonPath("$.data.refreshToken").exists());
        }

        @Test
        @DisplayName("리프레시 토큰 없이 요청하면 400 에러가 반환된다")
        void reissue_토큰누락_실패() throws Exception {
            mockMvc.perform(post("/api/v1/auth/reissue")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{}"))
                    .andDo(print())
                    .andExpect(status().isBadRequest());
        }
    }

    @Nested
    @DisplayName("이메일 인증 Mock 게이트")
    class VerificationGatingTest {

        @Test
        @DisplayName("Mock 인증이 비활성화(기본값)면 인증번호 발송이 503을 반환한다")
        void verificationSend_기본비활성화_503() throws Exception {
            mockMvc.perform(post("/api/v1/auth/verification/send")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"email\": \"gate-test@example.com\"}"))
                    .andDo(print())
                    .andExpect(status().isServiceUnavailable());
        }

        @Test
        @DisplayName("Mock 인증이 비활성화(기본값)면 인증번호 확인이 503을 반환한다")
        void verificationCheck_기본비활성화_503() throws Exception {
            mockMvc.perform(post("/api/v1/auth/verification/check")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"email\": \"gate-test@example.com\", \"code\": \"123456\"}"))
                    .andDo(print())
                    .andExpect(status().isServiceUnavailable());
        }
    }

    @Nested
    @DisplayName("JWT 필터 예외 처리")
    class JwtFilterErrorHandlingTest {

        @Test
        @DisplayName("잘못된 토큰으로 공개 엔드포인트에 접근해도 500이 아닌 정상 응답을 받는다")
        void 잘못된토큰_공개엔드포인트_정상응답() throws Exception {
            mockMvc.perform(get("/api/v1/artists")
                            .header("Authorization", "Bearer this-is-not-a-valid-jwt"))
                    .andDo(print())
                    .andExpect(status().isOk());
        }

        @Test
        @DisplayName("잘못된 토큰으로 보호된 엔드포인트에 접근하면 500이 아닌 401을 받는다")
        void 잘못된토큰_보호엔드포인트_401() throws Exception {
            mockMvc.perform(get("/api/v1/members/me")
                            .header("Authorization", "Bearer this-is-not-a-valid-jwt"))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("POST /api/v1/auth/sign-up")
    class SignUpTest {

        @Test
        @DisplayName("유효한 요청으로 회원가입이 성공한다")
        void signUp_성공() throws Exception {
            // given
            SignUpRequest request = new SignUpRequest("newuser@example.com", "password1", "새유저");

            // when & then
            mockMvc.perform(post("/api/v1/auth/sign-up")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.message").value("회원가입에 성공했습니다."));
        }

        @Test
        @DisplayName("이메일이 빈 값이면 400 에러가 반환된다")
        void signUp_이메일빈값_실패() throws Exception {
            // given
            SignUpRequest request = new SignUpRequest("", "password1", "테스트유저");

            // when & then
            mockMvc.perform(post("/api/v1/auth/sign-up")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isBadRequest());
        }

        @Test
        @DisplayName("비밀번호가 형식에 맞지 않으면 400 에러가 반환된다")
        void signUp_비밀번호형식오류_실패() throws Exception {
            // given
            SignUpRequest request = new SignUpRequest("user@example.com", "weak", "테스트유저");

            // when & then
            mockMvc.perform(post("/api/v1/auth/sign-up")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isBadRequest());
        }

        @Test
        @DisplayName("동일 이메일로 중복 가입하면 409 에러가 반환된다")
        void signUp_이메일중복_실패() throws Exception {
            // given - 첫 번째 가입
            SignUpRequest firstRequest = new SignUpRequest("dup@example.com", "password1", "유저1");
            mockMvc.perform(post("/api/v1/auth/sign-up")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(firstRequest)));

            // when - 동일 이메일로 재가입
            SignUpRequest duplicateRequest = new SignUpRequest("dup@example.com", "password2", "유저2");

            // then
            mockMvc.perform(post("/api/v1/auth/sign-up")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(duplicateRequest)))
                    .andDo(print())
                    .andExpect(status().isConflict());
        }
    }

    @Nested
    @DisplayName("POST /api/v1/auth/sign-in")
    class SignInTest {

        @Test
        @DisplayName("올바른 자격증명으로 로그인이 성공하고 토큰이 반환된다")
        void signIn_성공() throws Exception {
            // given - 먼저 회원가입
            SignUpRequest signUpRequest = new SignUpRequest("login@example.com", "password1", "로그인유저");
            mockMvc.perform(post("/api/v1/auth/sign-up")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(signUpRequest)));

            // when
            SignInRequest signInRequest = new SignInRequest("login@example.com", "password1");

            // then
            mockMvc.perform(post("/api/v1/auth/sign-in")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(signInRequest)))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.accessToken").exists())
                    .andExpect(jsonPath("$.data.refreshToken").exists());
        }

        @Test
        @DisplayName("잘못된 비밀번호로 로그인하면 401 에러가 반환된다")
        void signIn_잘못된비밀번호_실패() throws Exception {
            // given - 먼저 회원가입
            SignUpRequest signUpRequest = new SignUpRequest("wrong@example.com", "password1", "테스트유저2");
            mockMvc.perform(post("/api/v1/auth/sign-up")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(signUpRequest)));

            // when & then
            SignInRequest signInRequest = new SignInRequest("wrong@example.com", "wrongPassword1");
            mockMvc.perform(post("/api/v1/auth/sign-in")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(signInRequest)))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/auth/check-email")
    class CheckEmailTest {

        @Test
        @DisplayName("사용 가능한 이메일이면 성공 응답이 반환된다")
        void checkEmail_사용가능_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/auth/check-email")
                            .param("email", "available@example.com"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("이미 사용 중인 이메일이면 409 에러가 반환된다")
        void checkEmail_사용중_실패() throws Exception {
            // given - 먼저 회원가입
            SignUpRequest signUpRequest = new SignUpRequest("taken@example.com", "password1", "이메일점유");
            mockMvc.perform(post("/api/v1/auth/sign-up")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(signUpRequest)));

            // when & then
            mockMvc.perform(get("/api/v1/auth/check-email")
                            .param("email", "taken@example.com"))
                    .andDo(print())
                    .andExpect(status().isConflict());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/auth/check-nickname")
    class CheckNicknameTest {

        @Test
        @DisplayName("사용 가능한 닉네임이면 성공 응답이 반환된다")
        void checkNickname_사용가능_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/auth/check-nickname")
                            .param("nickname", "새닉네임"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("이미 사용 중인 닉네임이면 409 에러가 반환된다")
        void checkNickname_사용중_실패() throws Exception {
            // given - 먼저 회원가입
            SignUpRequest signUpRequest = new SignUpRequest("nick@example.com", "password1", "점유닉네임");
            mockMvc.perform(post("/api/v1/auth/sign-up")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(signUpRequest)));

            // when & then
            mockMvc.perform(get("/api/v1/auth/check-nickname")
                            .param("nickname", "점유닉네임"))
                    .andDo(print())
                    .andExpect(status().isConflict());
        }

        @Test
        @DisplayName("닉네임이 1글자이면 400 에러가 반환된다")
        void checkNickname_길이부족_실패() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/auth/check-nickname")
                            .param("nickname", "A"))
                    .andDo(print())
                    .andExpect(status().isBadRequest());
        }
    }
}
