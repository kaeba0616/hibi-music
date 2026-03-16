package com.hibi.server.domain.song.controller;

import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.artist.repository.ArtistRepository;
import com.hibi.server.domain.auth.dto.request.SignInRequest;
import com.hibi.server.domain.auth.dto.request.SignUpRequest;
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
import org.springframework.test.web.servlet.MvcResult;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("DailySongController 통합 테스트")
class DailySongControllerIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private SongRepository songRepository;

    @Autowired
    private ArtistRepository artistRepository;

    private Artist artist;
    private Song todaySong;
    private String accessToken;

    @BeforeEach
    void setUp() throws Exception {
        // 아티스트 생성
        artist = artistRepository.save(TestFixture.createArtist());

        // 오늘의 노래 생성
        todaySong = songRepository.save(
                TestFixture.createSongWithRecommendDate(artist, LocalDate.now())
        );

        // 테스트 유저 생성 및 토큰 발급
        SignUpRequest signUpRequest = new SignUpRequest("daily-song-test@example.com", "password1", "노래테스터");
        mockMvc.perform(post("/api/v1/auth/sign-up")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(signUpRequest)));

        SignInRequest signInRequest = new SignInRequest("daily-song-test@example.com", "password1");
        MvcResult result = mockMvc.perform(post("/api/v1/auth/sign-in")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(signInRequest)))
                .andReturn();

        String responseBody = result.getResponse().getContentAsString();
        accessToken = objectMapper.readTree(responseBody).path("data").path("accessToken").asText();
    }

    @Nested
    @DisplayName("GET /api/v1/daily-songs/today")
    class GetTodaySongTest {

        @Test
        @DisplayName("오늘의 노래가 있으면 노래 정보를 반환한다")
        void getTodaySong_노래있음_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/daily-songs/today"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.id").value(todaySong.getId()))
                    .andExpect(jsonPath("$.data.titleKor").value("오늘의 노래"));
        }

        @Test
        @DisplayName("오늘의 노래가 없으면 data가 null로 반환된다")
        void getTodaySong_노래없음_성공() throws Exception {
            // given - 오늘의 노래 삭제
            songRepository.delete(todaySong);

            // when & then
            mockMvc.perform(get("/api/v1/daily-songs/today"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data").doesNotExist());
        }

        @Test
        @DisplayName("인증된 유저도 오늘의 노래를 조회할 수 있다")
        void getTodaySong_인증유저_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/daily-songs/today")
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.id").value(todaySong.getId()));
        }
    }

    @Nested
    @DisplayName("GET /api/v1/daily-songs/by-date")
    class GetSongByDateTest {

        @Test
        @DisplayName("특정 날짜의 노래가 있으면 노래 정보를 반환한다")
        void getSongByDate_노래있음_성공() throws Exception {
            // given
            LocalDate date = LocalDate.now();

            // when & then
            mockMvc.perform(get("/api/v1/daily-songs/by-date")
                            .param("date", date.toString()))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.id").value(todaySong.getId()));
        }

        @Test
        @DisplayName("해당 날짜의 노래가 없으면 data가 null로 반환된다")
        void getSongByDate_노래없음_성공() throws Exception {
            // given
            LocalDate pastDate = LocalDate.of(2020, 1, 1);

            // when & then
            mockMvc.perform(get("/api/v1/daily-songs/by-date")
                            .param("date", pastDate.toString()))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data").doesNotExist());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/daily-songs/{songId}")
    class GetSongByIdTest {

        @Test
        @DisplayName("존재하는 노래 ID로 조회하면 노래 정보를 반환한다")
        void getSongById_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/daily-songs/{songId}", todaySong.getId()))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.id").value(todaySong.getId()))
                    .andExpect(jsonPath("$.data.titleKor").value("오늘의 노래"));
        }

        @Test
        @DisplayName("존재하지 않는 노래 ID로 조회하면 404 에러가 반환된다")
        void getSongById_없는노래_실패() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/daily-songs/{songId}", 99999L))
                    .andDo(print())
                    .andExpect(status().isNotFound());
        }
    }

    @Nested
    @DisplayName("GET /api/v1/daily-songs/by-month")
    class GetSongsByMonthTest {

        @Test
        @DisplayName("특정 연월의 노래 목록을 반환한다")
        void getSongsByMonth_성공() throws Exception {
            // given
            LocalDate now = LocalDate.now();

            // when & then
            mockMvc.perform(get("/api/v1/daily-songs/by-month")
                            .param("year", String.valueOf(now.getYear()))
                            .param("month", String.valueOf(now.getMonthValue())))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data").isArray())
                    .andExpect(jsonPath("$.data[0].id").value(todaySong.getId()));
        }

        @Test
        @DisplayName("해당 연월에 노래가 없으면 빈 배열을 반환한다")
        void getSongsByMonth_노래없음_빈배열() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/daily-songs/by-month")
                            .param("year", "2020")
                            .param("month", "1"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data").isArray())
                    .andExpect(jsonPath("$.data").isEmpty());
        }
    }

    @Nested
    @DisplayName("POST /api/v1/daily-songs/{songId}/like")
    class ToggleLikeTest {

        @Test
        @DisplayName("인증된 유저가 좋아요를 토글할 수 있다")
        void toggleLike_인증유저_성공() throws Exception {
            // when & then - 첫 번째 좋아요 (추가)
            mockMvc.perform(post("/api/v1/daily-songs/{songId}/like", todaySong.getId())
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.isLiked").value(true));
        }

        @Test
        @DisplayName("좋아요를 두 번 누르면 좋아요가 취소된다")
        void toggleLike_토글_성공() throws Exception {
            // given - 첫 번째 좋아요
            mockMvc.perform(post("/api/v1/daily-songs/{songId}/like", todaySong.getId())
                    .header("Authorization", "Bearer " + accessToken));

            // when & then - 두 번째 좋아요 (취소)
            mockMvc.perform(post("/api/v1/daily-songs/{songId}/like", todaySong.getId())
                            .header("Authorization", "Bearer " + accessToken))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.isLiked").value(false));
        }

        @Test
        @DisplayName("비인증 유저가 좋아요를 시도하면 401 에러가 반환된다")
        void toggleLike_비인증_실패() throws Exception {
            // when & then
            mockMvc.perform(post("/api/v1/daily-songs/{songId}/like", todaySong.getId()))
                    .andDo(print())
                    .andExpect(status().isUnauthorized());
        }
    }
}
