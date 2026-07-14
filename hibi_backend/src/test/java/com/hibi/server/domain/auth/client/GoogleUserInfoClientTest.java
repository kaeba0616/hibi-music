package com.hibi.server.domain.auth.client;

import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withStatus;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

@DisplayName("GoogleUserInfoClient 단위 테스트")
class GoogleUserInfoClientTest {

    private static final String USERINFO_URI = "https://www.googleapis.com/oauth2/v3/userinfo";

    private MockRestServiceServer server;
    private GoogleUserInfoClient client;

    @BeforeEach
    void setUp() {
        RestClient.Builder builder = RestClient.builder();
        server = MockRestServiceServer.bindTo(builder).build();
        client = new GoogleUserInfoClient(builder, USERINFO_URI);
    }

    @Test
    @DisplayName("유효한 액세스 토큰이면 구글 사용자 정보를 반환한다")
    void fetch_성공() {
        // given
        server.expect(requestTo(USERINFO_URI))
                .andExpect(header("Authorization", "Bearer valid-google-token"))
                .andRespond(withSuccess("""
                        {
                          "sub": "109876543210987654321",
                          "email": "hibi.user@gmail.com",
                          "email_verified": true,
                          "picture": "https://lh3.googleusercontent.com/photo.jpg"
                        }
                        """, MediaType.APPLICATION_JSON));

        // when
        SocialUserInfo userInfo = client.fetch("valid-google-token");

        // then
        assertThat(userInfo.providerId()).isEqualTo("109876543210987654321");
        assertThat(userInfo.email()).isEqualTo("hibi.user@gmail.com");
        assertThat(userInfo.profileUrl()).isEqualTo("https://lh3.googleusercontent.com/photo.jpg");
        server.verify();
    }

    @Test
    @DisplayName("만료/위조된 토큰(401)이면 SOCIAL_TOKEN_INVALID 예외가 발생한다")
    void fetch_잘못된토큰_예외() {
        // given
        server.expect(requestTo(USERINFO_URI))
                .andRespond(withStatus(HttpStatus.UNAUTHORIZED));

        // when & then
        assertThatThrownBy(() -> client.fetch("bad-token"))
                .isInstanceOf(CustomException.class)
                .satisfies(ex -> assertThat(((CustomException) ex).getErrorCode())
                        .isEqualTo(ErrorCode.SOCIAL_TOKEN_INVALID));
    }

    @Test
    @DisplayName("응답에 sub가 없으면 SOCIAL_TOKEN_INVALID 예외가 발생한다")
    void fetch_sub없음_예외() {
        // given
        server.expect(requestTo(USERINFO_URI))
                .andRespond(withSuccess("{}", MediaType.APPLICATION_JSON));

        // when & then
        assertThatThrownBy(() -> client.fetch("weird-token"))
                .isInstanceOf(CustomException.class)
                .satisfies(ex -> assertThat(((CustomException) ex).getErrorCode())
                        .isEqualTo(ErrorCode.SOCIAL_TOKEN_INVALID));
    }
}
