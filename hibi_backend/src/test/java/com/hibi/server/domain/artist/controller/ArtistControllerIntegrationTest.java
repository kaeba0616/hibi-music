package com.hibi.server.domain.artist.controller;

import com.hibi.server.domain.artist.dto.request.ArtistCreateRequest;
import com.hibi.server.domain.artist.dto.request.ArtistUpdateRequest;
import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.artist.repository.ArtistRepository;
import com.hibi.server.domain.auth.dto.request.SignInRequest;
import com.hibi.server.domain.auth.dto.request.SignUpRequest;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.MemberStatus;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.support.IntegrationTestSupport;
import com.hibi.server.support.TestFixture;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("ArtistController 통합 테스트")
class ArtistControllerIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private ArtistRepository artistRepository;

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private String userAccessToken;
    private String adminAccessToken;
    private Artist existingArtist;

    @BeforeEach
    void setUp() throws Exception {
        // 일반 유저 생성
        SignUpRequest userSignUp = new SignUpRequest("artist-test@example.com", "password1", "아티스트테스터");
        mockMvc.perform(post("/api/v1/auth/sign-up")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(userSignUp)));

        SignInRequest userSignIn = new SignInRequest("artist-test@example.com", "password1");
        MvcResult userResult = mockMvc.perform(post("/api/v1/auth/sign-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(userSignIn)))
                .andReturn();

        userAccessToken = objectMapper.readTree(userResult.getResponse().getContentAsString())
                .path("data").path("accessToken").asText();

        // 관리자 유저 직접 생성
        Member admin = Member.builder()
                .email("artist-admin@example.com")
                .password(passwordEncoder.encode("adminPassword1"))
                .nickname("아티스트관리자")
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.ADMIN)
                .status(MemberStatus.ACTIVE)
                .build();
        memberRepository.save(admin);

        SignInRequest adminSignIn = new SignInRequest("artist-admin@example.com", "adminPassword1");
        MvcResult adminResult = mockMvc.perform(post("/api/v1/auth/sign-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(adminSignIn)))
                .andReturn();

        adminAccessToken = objectMapper.readTree(adminResult.getResponse().getContentAsString())
                .path("data").path("accessToken").asText();

        // 테스트용 아티스트 생성
        existingArtist = artistRepository.save(TestFixture.createArtist("YOASOBI"));
    }

    @Nested
    @DisplayName("GET /api/v1/artists")
    class GetArtistListTest {

        @Test
        @DisplayName("아티스트 목록을 페이지네이션으로 조회한다")
        void getArtistList_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/artists")
                            .param("page", "0")
                            .param("size", "20"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.content").isArray());
        }

        @Test
        @DisplayName("검색어로 아티스트를 필터링할 수 있다")
        void getArtistList_검색_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/artists")
                            .param("search", "YOASOBI"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }
    }

    @Nested
    @DisplayName("GET /api/v1/artists/{id}")
    class GetArtistDetailTest {

        @Test
        @DisplayName("아티스트 상세 정보를 조회한다")
        void getArtistDetail_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/artists/{id}", existingArtist.getId()))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.nameKor").value("YOASOBI"));
        }

        @Test
        @DisplayName("존재하지 않는 아티스트 조회 시 404 에러가 반환된다")
        void getArtistDetail_없는아티스트_실패() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/artists/{id}", 99999L))
                    .andDo(print())
                    .andExpect(status().isNotFound());
        }
    }

    @Nested
    @DisplayName("POST /api/v1/artists/{id}/follow")
    class FollowArtistTest {

        @Test
        @DisplayName("인증된 유저가 아티스트를 팔로우할 수 있다")
        void follow_성공() throws Exception {
            // when & then
            mockMvc.perform(post("/api/v1/artists/{id}/follow", existingArtist.getId())
                            .header("Authorization", "Bearer " + userAccessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("비인증 유저는 아티스트를 팔로우할 수 없다")
        void follow_비인증_실패() throws Exception {
            // when & then
            mockMvc.perform(post("/api/v1/artists/{id}/follow", existingArtist.getId()))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("DELETE /api/v1/artists/{id}/follow")
    class UnfollowArtistTest {

        @Test
        @DisplayName("팔로우한 아티스트를 언팔로우할 수 있다")
        void unfollow_성공() throws Exception {
            // given - 먼저 팔로우
            mockMvc.perform(post("/api/v1/artists/{id}/follow", existingArtist.getId())
                    .header("Authorization", "Bearer " + userAccessToken));

            // when & then
            mockMvc.perform(delete("/api/v1/artists/{id}/follow", existingArtist.getId())
                            .header("Authorization", "Bearer " + userAccessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }
    }

    @Nested
    @DisplayName("POST /api/v1/artists (관리자)")
    class CreateArtistTest {

        @Test
        @DisplayName("관리자가 아티스트를 생성할 수 있다")
        void create_관리자_성공() throws Exception {
            // given
            ArtistCreateRequest request = new ArtistCreateRequest(
                    "Ado",
                    "Ado",
                    "アド"
            );

            // when & then
            mockMvc.perform(post("/api/v1/artists")
                            .header("Authorization", "Bearer " + adminAccessToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("일반 유저는 아티스트를 생성할 수 없다")
        void create_일반유저_실패() throws Exception {
            // given
            ArtistCreateRequest request = new ArtistCreateRequest(
                    "Ado",
                    "Ado",
                    "アド"
            );

            // when & then
            mockMvc.perform(post("/api/v1/artists")
                            .header("Authorization", "Bearer " + userAccessToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isForbidden());
        }
    }

    @Nested
    @DisplayName("PUT /api/v1/artists/{id} (관리자)")
    class UpdateArtistTest {

        @Test
        @DisplayName("관리자가 아티스트 정보를 수정할 수 있다")
        void update_관리자_성공() throws Exception {
            // given
            ArtistUpdateRequest request = new ArtistUpdateRequest(
                    "YOASOBI 수정",
                    "YOASOBI Updated",
                    "ヨアソビ更新",
                    "https://example.com/yoasobi-updated.jpg"
            );

            // when & then
            mockMvc.perform(put("/api/v1/artists/{id}", existingArtist.getId())
                            .header("Authorization", "Bearer " + adminAccessToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.nameKor").value("YOASOBI 수정"));
        }

        @Test
        @DisplayName("일반 유저는 아티스트 정보를 수정할 수 없다")
        void update_일반유저_실패() throws Exception {
            // given
            ArtistUpdateRequest request = new ArtistUpdateRequest(
                    "수정 시도",
                    "Update Attempt",
                    "更新試み",
                    "https://example.com/attempt.jpg"
            );

            // when & then
            mockMvc.perform(put("/api/v1/artists/{id}", existingArtist.getId())
                            .header("Authorization", "Bearer " + userAccessToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isForbidden());
        }
    }

    @Nested
    @DisplayName("DELETE /api/v1/artists/{id} (관리자)")
    class DeleteArtistTest {

        @Test
        @DisplayName("관리자가 아티스트를 삭제할 수 있다")
        void delete_관리자_성공() throws Exception {
            // given - 삭제용 아티스트 생성
            Artist toDelete = artistRepository.save(TestFixture.createArtist("삭제용"));

            // when & then
            mockMvc.perform(delete("/api/v1/artists/{id}", toDelete.getId())
                            .header("Authorization", "Bearer " + adminAccessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("일반 유저는 아티스트를 삭제할 수 없다")
        void delete_일반유저_실패() throws Exception {
            // when & then
            mockMvc.perform(delete("/api/v1/artists/{id}", existingArtist.getId())
                            .header("Authorization", "Bearer " + userAccessToken))
                    .andDo(print())
                    .andExpect(status().isForbidden());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/artists/all (관리자)")
    class GetAllArtistsTest {

        @Test
        @DisplayName("관리자가 모든 아티스트를 조회할 수 있다")
        void getAll_관리자_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/artists/all")
                            .header("Authorization", "Bearer " + adminAccessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data").isArray());
        }

        @Test
        @DisplayName("일반 유저는 전체 목록을 조회할 수 없다")
        void getAll_일반유저_실패() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/artists/all")
                            .header("Authorization", "Bearer " + userAccessToken))
                    .andDo(print())
                    .andExpect(status().isForbidden());
        }
    }
}
