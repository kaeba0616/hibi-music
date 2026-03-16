package com.hibi.server.domain.follow.controller;

import com.hibi.server.domain.auth.dto.request.SignInRequest;
import com.hibi.server.domain.auth.dto.request.SignUpRequest;
import com.hibi.server.domain.feedpost.entity.FeedPost;
import com.hibi.server.domain.feedpost.repository.FeedPostRepository;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.support.IntegrationTestSupport;
import com.hibi.server.support.TestFixture;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("FollowController 통합 테스트")
class FollowControllerIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private FeedPostRepository feedPostRepository;

    private String accessToken;
    private Long memberId;
    private Member currentUser;
    private Member targetUser;

    @BeforeEach
    void setUp() throws Exception {
        // 현재 유저 생성 및 토큰 발급
        SignUpRequest signUpRequest = new SignUpRequest("follow-test@example.com", "password1", "팔로우테스터");
        mockMvc.perform(post("/api/v1/auth/sign-up")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(signUpRequest)));

        SignInRequest signInRequest = new SignInRequest("follow-test@example.com", "password1");
        MvcResult result = mockMvc.perform(post("/api/v1/auth/sign-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(signInRequest)))
                .andReturn();

        String responseBody = result.getResponse().getContentAsString();
        accessToken = objectMapper.readTree(responseBody).path("data").path("accessToken").asText();
        memberId = objectMapper.readTree(responseBody).path("data").path("memberId").asLong();

        currentUser = memberRepository.findById(memberId).orElseThrow();

        // 타겟 유저 생성
        targetUser = memberRepository.save(TestFixture.createMember("target@example.com", "타겟유저"));

        // 타겟 유저의 게시글 생성
        feedPostRepository.save(TestFixture.createFeedPost(targetUser, "타겟 유저의 게시글"));
    }

    @Nested
    @DisplayName("GET /api/v1/users/{userId}")
    class GetUserProfileTest {

        @Test
        @DisplayName("사용자 프로필을 조회한다")
        void getUserProfile_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/users/{userId}", targetUser.getId()))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.nickname").value("타겟유저"));
        }

        @Test
        @DisplayName("존재하지 않는 사용자 조회 시 404 에러가 반환된다")
        void getUserProfile_없는사용자_실패() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/users/{userId}", 99999L))
                    .andDo(print())
                    .andExpect(status().isNotFound());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/users/{userId}/followers")
    class GetFollowersTest {

        @Test
        @DisplayName("팔로워 목록을 조회한다")
        void getFollowers_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/users/{userId}/followers", targetUser.getId())
                            .param("page", "0")
                            .param("size", "20"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.content").isArray());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/users/{userId}/followings")
    class GetFollowingsTest {

        @Test
        @DisplayName("팔로잉 목록을 조회한다")
        void getFollowings_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/users/{userId}/followings", targetUser.getId()))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.content").isArray());
        }
    }

    @Nested
    @DisplayName("POST /api/v1/users/{userId}/follow")
    class FollowTest {

        @Test
        @DisplayName("인증된 유저가 다른 유저를 팔로우할 수 있다")
        void follow_성공() throws Exception {
            // when & then
            mockMvc.perform(post("/api/v1/users/{userId}/follow", targetUser.getId())
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.message").value("팔로우 성공"));
        }

        @Test
        @DisplayName("비인증 유저는 팔로우할 수 없다")
        void follow_비인증_실패() throws Exception {
            // when & then
            mockMvc.perform(post("/api/v1/users/{userId}/follow", targetUser.getId()))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("자기 자신을 팔로우할 수 없다")
        void follow_자기자신_실패() throws Exception {
            // when & then
            mockMvc.perform(post("/api/v1/users/{userId}/follow", memberId)
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isBadRequest());
        }
    }

    @Nested
    @DisplayName("DELETE /api/v1/users/{userId}/follow")
    class UnfollowTest {

        @Test
        @DisplayName("팔로우한 유저를 언팔로우할 수 있다")
        void unfollow_성공() throws Exception {
            // given - 먼저 팔로우
            mockMvc.perform(post("/api/v1/users/{userId}/follow", targetUser.getId())
                    .header("Authorization", "Bearer " + accessToken));

            // when & then
            mockMvc.perform(delete("/api/v1/users/{userId}/follow", targetUser.getId())
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.message").value("언팔로우 성공"));
        }

        @Test
        @DisplayName("비인증 유저는 언팔로우할 수 없다")
        void unfollow_비인증_실패() throws Exception {
            // when & then
            mockMvc.perform(delete("/api/v1/users/{userId}/follow", targetUser.getId()))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/users/{userId}/posts")
    class GetUserPostsTest {

        @Test
        @DisplayName("사용자의 게시글 목록을 조회한다")
        void getUserPosts_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/users/{userId}/posts", targetUser.getId()))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.content").isArray())
                    .andExpect(jsonPath("$.data.content[0].content").value("타겟 유저의 게시글"));
        }
    }
}
