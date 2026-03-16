package com.hibi.server.domain.feedpost.controller;

import com.hibi.server.domain.auth.dto.request.SignInRequest;
import com.hibi.server.domain.auth.dto.request.SignUpRequest;
import com.hibi.server.domain.feedpost.dto.request.FeedPostCreateRequest;
import com.hibi.server.domain.feedpost.dto.request.FeedPostUpdateRequest;
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

import java.util.List;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("FeedPostController 통합 테스트")
class FeedPostControllerIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private FeedPostRepository feedPostRepository;

    @Autowired
    private MemberRepository memberRepository;

    private String accessToken;
    private Long memberId;
    private Member author;
    private FeedPost existingPost;

    @BeforeEach
    void setUp() throws Exception {
        // 테스트 유저 생성 및 토큰 발급
        SignUpRequest signUpRequest = new SignUpRequest("feedpost-test@example.com", "password1", "피드테스터");
        mockMvc.perform(post("/api/v1/auth/sign-up")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(signUpRequest)));

        SignInRequest signInRequest = new SignInRequest("feedpost-test@example.com", "password1");
        MvcResult result = mockMvc.perform(post("/api/v1/auth/sign-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(signInRequest)))
                .andReturn();

        String responseBody = result.getResponse().getContentAsString();
        accessToken = objectMapper.readTree(responseBody).path("data").path("accessToken").asText();
        memberId = objectMapper.readTree(responseBody).path("data").path("memberId").asLong();

        // 작성자 조회
        author = memberRepository.findById(memberId).orElseThrow();

        // 기존 게시글 생성
        existingPost = feedPostRepository.save(TestFixture.createFeedPost(author, "기존 게시글 내용입니다."));
    }

    @Nested
    @DisplayName("GET /api/v1/posts")
    class GetPostsTest {

        @Test
        @DisplayName("게시글 목록을 페이징하여 조회한다")
        void getPosts_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/posts")
                            .param("page", "0")
                            .param("size", "10"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.content").isArray())
                    .andExpect(jsonPath("$.data.content[0].id").value(existingPost.getId()));
        }

        @Test
        @DisplayName("인증된 유저도 게시글 목록을 조회할 수 있다")
        void getPosts_인증유저_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/posts")
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }
    }

    @Nested
    @DisplayName("GET /api/v1/posts/{postId}")
    class GetPostTest {

        @Test
        @DisplayName("존재하는 게시글을 상세 조회한다")
        void getPost_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/posts/{postId}", existingPost.getId()))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.id").value(existingPost.getId()))
                    .andExpect(jsonPath("$.data.content").value("기존 게시글 내용입니다."));
        }

        @Test
        @DisplayName("존재하지 않는 게시글 조회 시 404 에러가 반환된다")
        void getPost_없는게시글_실패() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/posts/{postId}", 99999L))
                    .andDo(print())
                    .andExpect(status().isNotFound());
        }
    }

    @Nested
    @DisplayName("POST /api/v1/posts")
    class CreatePostTest {

        @Test
        @DisplayName("인증된 유저가 게시글을 작성할 수 있다")
        void createPost_성공() throws Exception {
            // given
            FeedPostCreateRequest request = new FeedPostCreateRequest(
                    "새로운 게시글입니다.",
                    List.of(),
                    null
            );

            // when & then
            mockMvc.perform(post("/api/v1/posts")
                            .header("Authorization", "Bearer " + accessToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.content").value("새로운 게시글입니다."));
        }

        @Test
        @DisplayName("비인증 유저는 게시글을 작성할 수 없다")
        void createPost_비인증_실패() throws Exception {
            // given
            FeedPostCreateRequest request = new FeedPostCreateRequest(
                    "새로운 게시글입니다.",
                    List.of(),
                    null
            );

            // when & then
            mockMvc.perform(post("/api/v1/posts")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("내용이 비어있으면 400 에러가 반환된다")
        void createPost_빈내용_실패() throws Exception {
            // given
            FeedPostCreateRequest request = new FeedPostCreateRequest(
                    "",
                    List.of(),
                    null
            );

            // when & then
            mockMvc.perform(post("/api/v1/posts")
                            .header("Authorization", "Bearer " + accessToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isBadRequest());
        }
    }

    @Nested
    @DisplayName("PUT /api/v1/posts/{postId}")
    class UpdatePostTest {

        @Test
        @DisplayName("작성자가 자신의 게시글을 수정할 수 있다")
        void updatePost_성공() throws Exception {
            // given
            FeedPostUpdateRequest request = new FeedPostUpdateRequest(
                    "수정된 내용입니다.",
                    List.of(),
                    null
            );

            // when & then
            mockMvc.perform(put("/api/v1/posts/{postId}", existingPost.getId())
                            .header("Authorization", "Bearer " + accessToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.content").value("수정된 내용입니다."));
        }

        @Test
        @DisplayName("다른 사람의 게시글을 수정하려고 하면 403 에러가 반환된다")
        void updatePost_권한없음_실패() throws Exception {
            // given - 다른 유저 생성
            SignUpRequest otherSignUp = new SignUpRequest("other@example.com", "password1", "다른유저");
            mockMvc.perform(post("/api/v1/auth/sign-up")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(otherSignUp)));

            SignInRequest otherSignIn = new SignInRequest("other@example.com", "password1");
            MvcResult result = mockMvc.perform(post("/api/v1/auth/sign-in")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(otherSignIn)))
                    .andReturn();

            String otherToken = objectMapper.readTree(result.getResponse().getContentAsString())
                    .path("data").path("accessToken").asText();

            FeedPostUpdateRequest request = new FeedPostUpdateRequest(
                    "수정 시도",
                    List.of(),
                    null
            );

            // when & then
            mockMvc.perform(put("/api/v1/posts/{postId}", existingPost.getId())
                            .header("Authorization", "Bearer " + otherToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isForbidden());
        }
    }

    @Nested
    @DisplayName("DELETE /api/v1/posts/{postId}")
    class DeletePostTest {

        @Test
        @DisplayName("작성자가 자신의 게시글을 삭제할 수 있다")
        void deletePost_성공() throws Exception {
            // when & then
            mockMvc.perform(delete("/api/v1/posts/{postId}", existingPost.getId())
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("비인증 유저는 게시글을 삭제할 수 없다")
        void deletePost_비인증_실패() throws Exception {
            // when & then
            mockMvc.perform(delete("/api/v1/posts/{postId}", existingPost.getId()))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("POST /api/v1/posts/{postId}/like")
    class ToggleLikeTest {

        @Test
        @DisplayName("인증된 유저가 좋아요를 추가할 수 있다")
        void toggleLike_추가_성공() throws Exception {
            // when & then
            mockMvc.perform(post("/api/v1/posts/{postId}/like", existingPost.getId())
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data").value(true));
        }

        @Test
        @DisplayName("좋아요를 두 번 누르면 취소된다")
        void toggleLike_취소_성공() throws Exception {
            // given - 첫 번째 좋아요
            mockMvc.perform(post("/api/v1/posts/{postId}/like", existingPost.getId())
                    .header("Authorization", "Bearer " + accessToken));

            // when & then - 두 번째 좋아요 (취소)
            mockMvc.perform(post("/api/v1/posts/{postId}/like", existingPost.getId())
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data").value(false));
        }

        @Test
        @DisplayName("비인증 유저는 좋아요를 할 수 없다")
        void toggleLike_비인증_실패() throws Exception {
            // when & then
            mockMvc.perform(post("/api/v1/posts/{postId}/like", existingPost.getId()))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/posts/following")
    class GetFollowingFeedTest {

        @Test
        @DisplayName("팔로잉 피드를 조회할 수 있다")
        void getFollowingFeed_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/posts/following")
                            .header("Authorization", "Bearer " + accessToken)
                            .param("page", "0")
                            .param("size", "10"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.content").isArray());
        }

        @Test
        @DisplayName("비인증 유저는 팔로잉 피드를 조회할 수 없다")
        void getFollowingFeed_비인증_실패() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/posts/following"))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }
    }
}
