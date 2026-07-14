package com.hibi.server.domain.auth.client;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

/**
 * 구글 OAuth2 사용자 정보 조회 클라이언트.
 * 클라이언트(앱)가 발급받은 액세스 토큰을 구글 userinfo 엔드포인트로 검증하고
 * 사용자 식별 정보(sub/email/picture)를 가져온다.
 */
@Slf4j
@Component
public class GoogleUserInfoClient {

    private final RestClient restClient;
    private final String userInfoUri;

    public GoogleUserInfoClient(
            RestClient.Builder restClientBuilder,
            @Value("${auth.social.google.userinfo-uri:https://www.googleapis.com/oauth2/v3/userinfo}")
            String userInfoUri
    ) {
        this.restClient = restClientBuilder.build();
        this.userInfoUri = userInfoUri;
    }

    public SocialUserInfo fetch(String accessToken) {
        GoogleUserInfoResponse body;
        try {
            body = restClient.get()
                    .uri(userInfoUri)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken)
                    .retrieve()
                    .body(GoogleUserInfoResponse.class);
        } catch (RestClientResponseException e) {
            log.warn("구글 사용자 정보 조회 실패 - status: {}", e.getStatusCode());
            throw new CustomException(ErrorCode.SOCIAL_TOKEN_INVALID);
        } catch (RestClientException e) {
            log.error("구글 사용자 정보 조회 중 통신 오류", e);
            throw new CustomException(ErrorCode.SOCIAL_LOGIN_NOT_AVAILABLE);
        }

        if (body == null || body.sub() == null || body.sub().isBlank()) {
            log.warn("구글 사용자 정보 응답에 sub가 없습니다");
            throw new CustomException(ErrorCode.SOCIAL_TOKEN_INVALID);
        }

        return new SocialUserInfo(body.email(), body.sub(), body.picture());
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    record GoogleUserInfoResponse(
            String sub,
            String email,
            String picture
    ) {
    }
}
