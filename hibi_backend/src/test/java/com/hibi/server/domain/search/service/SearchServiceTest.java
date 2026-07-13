package com.hibi.server.domain.search.service;

import com.hibi.server.domain.artist.repository.ArtistRepository;
import com.hibi.server.domain.artistfollow.repository.ArtistFollowRepository;
import com.hibi.server.domain.feedpost.repository.FeedPostRepository;
import com.hibi.server.domain.follow.repository.MemberFollowRepository;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.search.dto.response.SearchResponse;
import com.hibi.server.domain.song.repository.SongRepository;
import com.hibi.server.support.ServiceTestSupport;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.data.domain.Pageable;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;

@DisplayName("SearchService 단위 테스트")
class SearchServiceTest extends ServiceTestSupport {

    @Mock
    private SongRepository songRepository;

    @Mock
    private ArtistRepository artistRepository;

    @Mock
    private FeedPostRepository feedPostRepository;

    @Mock
    private MemberRepository memberRepository;

    @Mock
    private ArtistFollowRepository artistFollowRepository;

    @Mock
    private MemberFollowRepository memberFollowRepository;

    @InjectMocks
    private SearchService searchService;

    @Test
    @DisplayName("검색 시 limit이 DB 쿼리(Pageable)로 전달된다")
    void search_limit_DB쿼리전달() {
        // given
        given(songRepository.searchByKeyword(eq("yoasobi"), any(Pageable.class)))
                .willReturn(List.of());
        given(artistRepository.searchByKeyword(eq("yoasobi"), any(Pageable.class)))
                .willReturn(List.of());
        given(feedPostRepository.searchByKeyword(eq("yoasobi"), any(Pageable.class)))
                .willReturn(List.of());
        given(memberRepository.searchByKeyword(eq("yoasobi"), any(Pageable.class)))
                .willReturn(List.of());

        // when
        SearchResponse response = searchService.search("yoasobi", "all", 5);

        // then
        assertThat(response).isNotNull();
        ArgumentCaptor<Pageable> pageableCaptor = ArgumentCaptor.forClass(Pageable.class);
        then(songRepository).should().searchByKeyword(eq("yoasobi"), pageableCaptor.capture());
        assertThat(pageableCaptor.getValue().getPageSize()).isEqualTo(5);
    }

    @Test
    @DisplayName("limit이 최대치를 초과하면 50으로 제한된다")
    void search_limit_최대치제한() {
        // given
        given(songRepository.searchByKeyword(eq("ado"), any(Pageable.class)))
                .willReturn(List.of());

        // when
        searchService.search("ado", "songs", 500);

        // then
        ArgumentCaptor<Pageable> pageableCaptor = ArgumentCaptor.forClass(Pageable.class);
        then(songRepository).should().searchByKeyword(eq("ado"), pageableCaptor.capture());
        assertThat(pageableCaptor.getValue().getPageSize()).isEqualTo(50);
    }
}
