package com.hibi.server.domain.song.controller;

import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.artist.repository.ArtistRepository;
import com.hibi.server.domain.auth.dto.request.SignInRequest;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.MemberStatus;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.song.dto.request.SongCreateRequest;
import com.hibi.server.domain.song.entity.Song;
import com.hibi.server.domain.song.repository.SongRepository;
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

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("SongController 통합 테스트")
class SongControllerIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private ArtistRepository artistRepository;

    @Autowired
    private SongRepository songRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private String userAccessToken;
    private String adminAccessToken;
    private Artist artist;

    @BeforeEach
    void setUp() throws Exception {
        Member user = Member.builder()
                .email("song-user@example.com")
                .password(passwordEncoder.encode("password1"))
                .nickname("노래유저")
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.USER)
                .status(MemberStatus.ACTIVE)
                .build();
        memberRepository.save(user);
        userAccessToken = signInAndGetToken("song-user@example.com", "password1");

        Member admin = Member.builder()
                .email("song-admin@example.com")
                .password(passwordEncoder.encode("adminPassword1"))
                .nickname("노래관리자")
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.ADMIN)
                .status(MemberStatus.ACTIVE)
                .build();
        memberRepository.save(admin);
        adminAccessToken = signInAndGetToken("song-admin@example.com", "adminPassword1");

        artist = artistRepository.save(TestFixture.createArtist());
    }

    private String signInAndGetToken(String email, String password) throws Exception {
        SignInRequest signIn = new SignInRequest(email, password);
        MvcResult result = mockMvc.perform(post("/api/v1/auth/sign-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(signIn)))
                .andReturn();
        return objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data").path("accessToken").asText();
    }

    @Nested
    @DisplayName("POST /api/v1/songs")
    class CreateSongTest {

        @Test
        @DisplayName("미인증 사용자는 노래를 생성할 수 없다")
        void createSong_미인증_실패() throws Exception {
            SongCreateRequest request = new SongCreateRequest("제목", "Title", "タイトル", artist.getId());

            mockMvc.perform(post("/api/v1/songs")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request)))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("일반 유저는 노래를 생성할 수 없다 (403)")
        void createSong_일반유저_실패() throws Exception {
            SongCreateRequest request = new SongCreateRequest("제목", "Title", "タイトル", artist.getId());

            mockMvc.perform(post("/api/v1/songs")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request))
                            .header("Authorization", "Bearer " + userAccessToken))
                    .andDo(print())
                    .andExpect(status().isForbidden());
        }

        @Test
        @DisplayName("관리자는 노래를 생성할 수 있다")
        void createSong_관리자_성공() throws Exception {
            SongCreateRequest request = new SongCreateRequest("제목", "Title", "タイトル", artist.getId());

            mockMvc.perform(post("/api/v1/songs")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(request))
                            .header("Authorization", "Bearer " + adminAccessToken))
                    .andDo(print())
                    .andExpect(status().isOk());
        }
    }

    @Nested
    @DisplayName("DELETE /api/v1/songs/{id}")
    class DeleteSongTest {

        @Test
        @DisplayName("일반 유저는 노래를 삭제할 수 없다 (403)")
        void deleteSong_일반유저_실패() throws Exception {
            Song song = songRepository.save(TestFixture.createSong(artist));

            mockMvc.perform(delete("/api/v1/songs/{id}", song.getId())
                            .header("Authorization", "Bearer " + userAccessToken))
                    .andDo(print())
                    .andExpect(status().isForbidden());

            assertThat(songRepository.existsById(song.getId())).isTrue();
        }

        @Test
        @DisplayName("관리자가 삭제하면 노래가 실제로 삭제된다")
        void deleteSong_관리자_실제삭제() throws Exception {
            Song song = songRepository.save(TestFixture.createSong(artist));

            mockMvc.perform(delete("/api/v1/songs/{id}", song.getId())
                            .header("Authorization", "Bearer " + adminAccessToken))
                    .andDo(print())
                    .andExpect(status().isOk());

            assertThat(songRepository.existsById(song.getId())).isFalse();
        }
    }
}
