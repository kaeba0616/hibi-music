package com.hibi.server.domain.auth.controller;

import com.hibi.server.domain.auth.dto.request.VerificationCheckRequest;
import com.hibi.server.domain.auth.dto.request.VerificationSendRequest;
import com.hibi.server.support.IntegrationTestSupport;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("VerificationController 통합 테스트")
class VerificationControllerTest extends IntegrationTestSupport {

    @Nested
    @DisplayName("POST /api/v1/auth/verification/send")
    class SendVerificationTest {

        @Test
        @DisplayName("유효한 이메일로 인증번호 발송이 성공한다")
        void sendVerification_성공() throws Exception {
            // given
            VerificationSendRequest request = new VerificationSendRequest("test@example.com");

            // when & then
            mockMvc.perform(post("/api/v1/auth/verification/send")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.message").value("인증번호가 발송되었습니다."));
        }
    }

    @Nested
    @DisplayName("POST /api/v1/auth/verification/check")
    class CheckVerificationTest {

        @Test
        @DisplayName("올바른 인증번호(123456)로 인증이 성공한다")
        void checkVerification_성공() throws Exception {
            // given
            VerificationCheckRequest request = new VerificationCheckRequest("test@example.com", "123456");

            // when & then
            mockMvc.perform(post("/api/v1/auth/verification/check")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.message").value("인증이 완료되었습니다."));
        }

        @Test
        @DisplayName("잘못된 인증번호로 인증이 실패한다")
        void checkVerification_잘못된코드_실패() throws Exception {
            // given
            VerificationCheckRequest request = new VerificationCheckRequest("test@example.com", "999999");

            // when & then
            mockMvc.perform(post("/api/v1/auth/verification/check")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isBadRequest())
                    .andExpect(jsonPath("$.message").value("인증번호가 올바르지 않습니다."));
        }
    }
}
