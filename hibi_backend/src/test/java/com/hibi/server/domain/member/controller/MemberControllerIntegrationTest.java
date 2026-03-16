package com.hibi.server.domain.member.controller;

import com.hibi.server.domain.auth.dto.request.SignInRequest;
import com.hibi.server.domain.auth.dto.request.SignUpRequest;
import com.hibi.server.domain.member.dto.request.MemberUpdateRequest;
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

@DisplayName("MemberController 통합 테스트")
class MemberControllerIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private String userAccessToken;
    private String adminAccessToken;
    private Long memberId;
    private Member otherMember;

    @BeforeEach
    void setUp() throws Exception {
        // 일반 유저 생성
        SignUpRequest userSignUp = new SignUpRequest("member-test@example.com", "password1", "멤버테스터");
        mockMvc.perform(post("/api/v1/auth/sign-up")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(userSignUp)));

        SignInRequest userSignIn = new SignInRequest("member-test@example.com", "password1");
        MvcResult userResult = mockMvc.perform(post("/api/v1/auth/sign-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(userSignIn)))
                .andReturn();

        String responseBody = userResult.getResponse().getContentAsString();
        userAccessToken = objectMapper.readTree(responseBody).path("data").path("accessToken").asText();
        memberId = objectMapper.readTree(responseBody).path("data").path("memberId").asLong();

        // 관리자 유저 직접 생성
        Member admin = Member.builder()
                .email("member-admin@example.com")
                .password(passwordEncoder.encode("adminPassword1"))
                .nickname("멤버관리자")
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.ADMIN)
                .status(MemberStatus.ACTIVE)
                .build();
        memberRepository.save(admin);

        SignInRequest adminSignIn = new SignInRequest("member-admin@example.com", "adminPassword1");
        MvcResult adminResult = mockMvc.perform(post("/api/v1/auth/sign-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(adminSignIn)))
                .andReturn();

        adminAccessToken = objectMapper.readTree(adminResult.getResponse().getContentAsString())
                .path("data").path("accessToken").asText();

        // 다른 회원 생성
        otherMember = memberRepository.save(TestFixture.createMember("other-member@example.com", "다른회원"));
    }

    @Nested
    @DisplayName("GET /api/v1/members/me")
    class GetMyInfoTest {

        @Test
        @DisplayName("인증된 유저가 자신의 정보를 조회한다")
        void getMyInfo_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/members/me")
                            .header("Authorization", "Bearer " + userAccessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.email").value("member-test@example.com"))
                    .andExpect(jsonPath("$.data.nickname").value("멤버테스터"));
        }

        @Test
        @DisplayName("비인증 유저는 자신의 정보를 조회할 수 없다")
        void getMyInfo_비인증_실패() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/members/me"))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/members/info/{memberId}")
    class GetMemberByIdTest {

        @Test
        @DisplayName("특정 회원의 공개 프로필을 조회한다")
        void getMemberById_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/members/info/{memberId}", otherMember.getId()))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.nickname").value("다른회원"));
        }

        @Test
        @DisplayName("존재하지 않는 회원 조회 시 404 에러가 반환된다")
        void getMemberById_없는회원_실패() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/members/info/{memberId}", 99999L))
                    .andDo(print())
                    .andExpect(status().isNotFound());
        }
    }

    @Nested
    @DisplayName("PATCH /api/v1/members/me")
    class UpdateMyInfoTest {

        @Test
        @DisplayName("인증된 유저가 자신의 정보를 수정한다")
        void updateMyInfo_성공() throws Exception {
            // given
            MemberUpdateRequest request = new MemberUpdateRequest("수정된닉네임", "newPassword1");

            // when & then
            mockMvc.perform(patch("/api/v1/members/me")
                            .header("Authorization", "Bearer " + userAccessToken)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.nickname").value("수정된닉네임"));
        }

        @Test
        @DisplayName("비인증 유저는 정보를 수정할 수 없다")
        void updateMyInfo_비인증_실패() throws Exception {
            // given
            MemberUpdateRequest request = new MemberUpdateRequest("수정닉네임", "newPassword1");

            // when & then
            mockMvc.perform(patch("/api/v1/members/me")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("DELETE /api/v1/members/me")
    class WithdrawMemberTest {

        @Test
        @DisplayName("인증된 유저가 회원 탈퇴를 할 수 있다")
        void withdraw_성공() throws Exception {
            // given - 탈퇴 테스트용 유저 생성
            SignUpRequest withdrawUser = new SignUpRequest("withdraw@example.com", "password1", "탈퇴유저");
            mockMvc.perform(post("/api/v1/auth/sign-up")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(withdrawUser)));

            SignInRequest withdrawSignIn = new SignInRequest("withdraw@example.com", "password1");
            MvcResult result = mockMvc.perform(post("/api/v1/auth/sign-in")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(withdrawSignIn)))
                    .andReturn();

            String withdrawToken = objectMapper.readTree(result.getResponse().getContentAsString())
                    .path("data").path("accessToken").asText();

            // when & then
            mockMvc.perform(delete("/api/v1/members/me")
                            .header("Authorization", "Bearer " + withdrawToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("비인증 유저는 탈퇴할 수 없다")
        void withdraw_비인증_실패() throws Exception {
            // when & then
            mockMvc.perform(delete("/api/v1/members/me"))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/members (관리자)")
    class GetAllMembersTest {

        @Test
        @DisplayName("관리자가 모든 회원 목록을 조회할 수 있다")
        void getAllMembers_관리자_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/members")
                            .header("Authorization", "Bearer " + adminAccessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data").isArray());
        }

        @Test
        @DisplayName("일반 유저는 모든 회원 목록을 조회할 수 없다")
        void getAllMembers_일반유저_실패() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/members")
                            .header("Authorization", "Bearer " + userAccessToken))
                    .andDo(print())
                    .andExpect(status().isForbidden());
        }
    }
}
