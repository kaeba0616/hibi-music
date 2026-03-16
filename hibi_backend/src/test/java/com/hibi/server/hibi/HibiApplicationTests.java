package com.hibi.server.hibi;

import com.hibi.server.support.IntegrationTestSupport;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class HibiApplicationTests extends IntegrationTestSupport {

    @Test
    @DisplayName("Spring Boot 컨텍스트가 정상적으로 로드된다")
    void contextLoads() {
        assertThat(mockMvc).isNotNull();
        assertThat(objectMapper).isNotNull();
    }
}
