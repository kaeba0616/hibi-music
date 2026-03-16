package com.hibi.server.domain.search.controller;

import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.artist.repository.ArtistRepository;
import com.hibi.server.domain.auth.dto.request.SignUpRequest;
import com.hibi.server.domain.feedpost.entity.FeedPost;
import com.hibi.server.domain.feedpost.repository.FeedPostRepository;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.repository.MemberRepository;
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

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("SearchController 통합 테스트")
class SearchControllerIntegrationTest extends IntegrationTestSupport {

    @Autowired
    private ArtistRepository artistRepository;

    @Autowired
    private SongRepository songRepository;

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private FeedPostRepository feedPostRepository;

    private Artist artist;
    private Song song;
    private Member member;
    private FeedPost post;

    @BeforeEach
    void setUp() throws Exception {
        // 테스트 데이터 생성
        artist = artistRepository.save(TestFixture.createArtist("검색용아티스트"));
        song = songRepository.save(TestFixture.createSong("검색용노래", artist));

        // 유저 생성
        SignUpRequest userSignUp = new SignUpRequest("search-test@example.com", "password1", "검색용유저");
        mockMvc.perform(post("/api/v1/auth/sign-up")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(userSignUp)));

        member = memberRepository.findByEmail("search-test@example.com").orElseThrow();

        // 게시글 생성
        post = feedPostRepository.save(TestFixture.createFeedPost(member, "검색용 게시글 내용입니다."));
    }

    @Nested
    @DisplayName("GET /api/v1/search")
    class SearchTest {

        @Test
        @DisplayName("통합 검색으로 전체 카테고리를 검색한다")
        void search_전체카테고리_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/search")
                            .param("q", "검색")
                            .param("category", "all"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.data.keyword").value("검색"));
        }

        @Test
        @DisplayName("노래 카테고리만 검색한다")
        void search_노래카테고리_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/search")
                            .param("q", "검색용노래")
                            .param("category", "songs"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("아티스트 카테고리만 검색한다")
        void search_아티스트카테고리_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/search")
                            .param("q", "검색용아티스트")
                            .param("category", "artists"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("게시글 카테고리만 검색한다")
        void search_게시글카테고리_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/search")
                            .param("q", "게시글")
                            .param("category", "posts"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("유저 카테고리만 검색한다")
        void search_유저카테고리_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/search")
                            .param("q", "검색용유저")
                            .param("category", "users"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("검색어가 비어있으면 400 에러가 반환된다")
        void search_빈검색어_실패() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/search")
                            .param("q", ""))
                    .andDo(print())
                    .andExpect(status().isBadRequest());
        }

        @Test
        @DisplayName("검색 결과가 없으면 빈 결과를 반환한다")
        void search_결과없음_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/search")
                            .param("q", "존재하지않는키워드12345"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.message").value("검색 결과가 없습니다"));
        }

        @Test
        @DisplayName("limit 파라미터로 결과 수를 제한할 수 있다")
        void search_limit적용_성공() throws Exception {
            // when & then
            mockMvc.perform(get("/api/v1/search")
                            .param("q", "검색")
                            .param("limit", "5"))
                    .andDo(print())
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }
    }
}
