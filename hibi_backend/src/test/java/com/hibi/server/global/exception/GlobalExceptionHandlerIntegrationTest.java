package com.hibi.server.global.exception;

import com.hibi.server.support.IntegrationTestSupport;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.hamcrest.Matchers.not;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.hamcrest.Matchers.containsString;

@DisplayName("GlobalExceptionHandler 통합 테스트")
class GlobalExceptionHandlerIntegrationTest extends IntegrationTestSupport {

    @Test
    @DisplayName("경로 변수 타입이 맞지 않으면 500이 아닌 400을 반환한다")
    void 타입불일치_400() throws Exception {
        mockMvc.perform(get("/api/v1/artists/{id}", "not-a-number"))
                .andDo(print())
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("잘못된 날짜 형식 파라미터는 500이 아닌 400을 반환한다")
    void 날짜형식오류_400() throws Exception {
        mockMvc.perform(get("/api/v1/daily-songs/by-date").param("date", "not-a-date"))
                .andDo(print())
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("에러 응답의 type URL은 base-url을 그대로 사용한다 (scheme/port 중복 없음)")
    void 에러응답_type_URL_정상조립() throws Exception {
        // 테스트 설정의 api.base-url = http://localhost:8080
        mockMvc.perform(get("/api/v1/artists/{id}", "not-a-number"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.type").value("http://localhost:8080/swagger-ui/index.html#/"))
                .andExpect(jsonPath("$.type").value(not(containsString("http://http"))))
                .andExpect(jsonPath("$.instance").value(not(containsString("http://http"))));
    }
}
