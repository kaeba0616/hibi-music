package com.hibi.server.domain.comment.controller;

import com.hibi.server.domain.auth.dto.request.SignInRequest;
import com.hibi.server.domain.auth.dto.request.SignUpRequest;
import com.hibi.server.domain.comment.dto.request.CommentCreateRequest;
import com.hibi.server.domain.comment.entity.Comment;
import com.hibi.server.domain.comment.repository.CommentRepository;
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

@DisplayName("CommentController 통합 테스트")
class CommentControllerIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private CommentRepository commentRepository;

    @Autowired
    private FeedPostRepository feedPostRepository;

    @Autowired
    private MemberRepository memberRepository;

    private String accessToken;
    private Long memberId;
    private Member author;
    private FeedPost post;
    private Comment existingComment;

    @BeforeEach
    void setUp() throws Exception {
        // 테스트 유저 생성 및 토큰 발급
        SignUpRequest signUpRequest = new SignUpRequest("comment-test@example.com", "password1", "댓글테스터");
        mockMvc.perform(post("/api/v1/auth/sign-up")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(signUpRequest)));

        SignInRequest signInRequest = new SignInRequest("comment-test@example.com", "password1");
        MvcResult result = mockMvc.perform(post("/api/v1/auth/sign-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(signInRequest)))
                .andReturn();

        String responseBody = result.getResponse().getContentAsString();
        accessToken = objectMapper.readTree(responseBody).path("data").path("accessToken").asText();
        memberId = objectMapper.readTree(responseBody).path("data").path("memberId").asLong();

        // 작성자 조회
        author = memberRepository.findById(memberId).orElseThrow();

        // 게시글 생성
        post = feedPostRepository.save(TestFixture.createFeedPost(author, "테스트 게시글"));

        // 기존 댓글 생성
        existingComment = commentRepository.save(TestFixture.createComment(post, author, "기존 댓글입니다."));
    }

    @Nested
    @DisplayName("GET /api/v1/posts/{postId}/comments")
    class GetCommentsTest {

        @Test
        @DisplayName("게시글의 댓글 목록을 조회한다")
        void getComments_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/posts/{postId}/comments", post.getId()))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.comments").isArray())
                    .andExpect(jsonPath("$.data.comments[0].content").value("기존 댓글입니다."));
        }

        @Test
        @DisplayName("인증된 유저도 댓글 목록을 조회할 수 있다")
        void getComments_인증유저_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/posts/{postId}/comments", post.getId())
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }
    }

    @Nested
    @DisplayName("POST /api/v1/posts/{postId}/comments")
    class CreateCommentTest {

        @Test
        @DisplayName("인증된 유저가 댓글을 작성할 수 있다")
        void createComment_성공() throws Exception {
            // given
            CommentCreateRequest request = new CommentCreateRequest("새로운 댓글입니다.", null);

            // when & then
            mockMvc.perform(post("/api/v1/posts/{postId}/comments", post.getId())
                            .header("Authorization", "Bearer " + accessToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.content").value("새로운 댓글입니다."));
        }

        @Test
        @DisplayName("대댓글을 작성할 수 있다")
        void createComment_대댓글_성공() throws Exception {
            // given
            CommentCreateRequest request = new CommentCreateRequest("대댓글입니다.", existingComment.getId());

            // when & then
            mockMvc.perform(post("/api/v1/posts/{postId}/comments", post.getId())
                            .header("Authorization", "Bearer " + accessToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.content").value("대댓글입니다."));
        }

        @Test
        @DisplayName("비인증 유저는 댓글을 작성할 수 없다")
        void createComment_비인증_실패() throws Exception {
            // given
            CommentCreateRequest request = new CommentCreateRequest("댓글 시도", null);

            // when & then
            mockMvc.perform(post("/api/v1/posts/{postId}/comments", post.getId())
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("내용이 비어있으면 400 에러가 반환된다")
        void createComment_빈내용_실패() throws Exception {
            // given
            CommentCreateRequest request = new CommentCreateRequest("", null);

            // when & then
            mockMvc.perform(post("/api/v1/posts/{postId}/comments", post.getId())
                            .header("Authorization", "Bearer " + accessToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isBadRequest());
        }
    }

    @Nested
    @DisplayName("DELETE /api/v1/posts/{postId}/comments/{commentId}")
    class DeleteCommentTest {

        @Test
        @DisplayName("작성자가 자신의 댓글을 삭제할 수 있다")
        void deleteComment_성공() throws Exception {
            // when & then
            mockMvc.perform(delete("/api/v1/posts/{postId}/comments/{commentId}",
                            post.getId(), existingComment.getId())
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("다른 사람의 댓글을 삭제하려고 하면 403 에러가 반환된다")
        void deleteComment_권한없음_실패() throws Exception {
            // given - 다른 유저 생성
            SignUpRequest otherSignUp = new SignUpRequest("other-comment@example.com", "password1", "다른유저2");
            mockMvc.perform(post("/api/v1/auth/sign-up")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(otherSignUp)));

            SignInRequest otherSignIn = new SignInRequest("other-comment@example.com", "password1");
            MvcResult result = mockMvc.perform(post("/api/v1/auth/sign-in")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(otherSignIn)))
                    .andReturn();

            String otherToken = objectMapper.readTree(result.getResponse().getContentAsString())
                    .path("data").path("accessToken").asText();

            // when & then
            mockMvc.perform(delete("/api/v1/posts/{postId}/comments/{commentId}",
                            post.getId(), existingComment.getId())
                            .header("Authorization", "Bearer " + otherToken))
                    .andDo(print())
                    .andExpect(status().isForbidden());
        }

        @Test
        @DisplayName("비인증 유저는 댓글을 삭제할 수 없다")
        void deleteComment_비인증_실패() throws Exception {
            // when & then
            mockMvc.perform(delete("/api/v1/posts/{postId}/comments/{commentId}",
                            post.getId(), existingComment.getId()))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("POST /api/v1/posts/{postId}/comments/{commentId}/like")
    class ToggleLikeTest {

        @Test
        @DisplayName("인증된 유저가 댓글에 좋아요를 추가할 수 있다")
        void toggleLike_추가_성공() throws Exception {
            // when & then
            mockMvc.perform(post("/api/v1/posts/{postId}/comments/{commentId}/like",
                            post.getId(), existingComment.getId())
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
            mockMvc.perform(post("/api/v1/posts/{postId}/comments/{commentId}/like",
                    post.getId(), existingComment.getId())
                    .header("Authorization", "Bearer " + accessToken));

            // when & then - 두 번째 좋아요 (취소)
            mockMvc.perform(post("/api/v1/posts/{postId}/comments/{commentId}/like",
                            post.getId(), existingComment.getId())
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data").value(false));
        }

        @Test
        @DisplayName("비인증 유저는 좋아요를 할 수 없다")
        void toggleLike_비인증_실패() throws Exception {
            // when & then
            mockMvc.perform(post("/api/v1/posts/{postId}/comments/{commentId}/like",
                            post.getId(), existingComment.getId()))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }
    }
}
