package com.hibi.server.domain.song.service;

import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.song.dto.response.DailySongResponse;
import com.hibi.server.domain.song.dto.response.RelatedSongResponse;
import com.hibi.server.domain.song.entity.RelatedSong;
import com.hibi.server.domain.song.entity.Song;
import com.hibi.server.domain.song.repository.RelatedSongRepository;
import com.hibi.server.domain.song.repository.SongRepository;
import com.hibi.server.domain.songlike.service.SongLikeService;
import com.hibi.server.support.ServiceTestSupport;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.BDDMockito.given;

@DisplayName("DailySongService 연관곡/좋아요 단위 테스트")
class RelatedSongServiceTest extends ServiceTestSupport {

    @Mock
    private SongRepository songRepository;

    @Mock
    private RelatedSongRepository relatedSongRepository;

    @Mock
    private SongLikeService songLikeService;

    @InjectMocks
    private DailySongService dailySongService;

    private Artist createTestArtist() {
        return Artist.builder()
                .id(1L)
                .nameKor("테스트 아티스트")
                .nameEng("Test Artist")
                .nameJp("テストアーティスト")
                .build();
    }

    private Song createTestSong(Long id, Artist artist) {
        return Song.builder()
                .id(id)
                .titleKor("테스트 곡")
                .titleJp("テスト曲")
                .artist(artist)
                .build();
    }

    @Nested
    @DisplayName("getRelatedSongs 메서드")
    class GetRelatedSongsTest {

        @Test
        @DisplayName("연관곡 목록을 반환한다")
        void getRelatedSongs_목록반환_성공() {
            // given
            Long songId = 1L;
            Artist artist = createTestArtist();
            Song relatedSongRef = createTestSong(2L, artist);

            RelatedSong relatedSong = RelatedSong.builder()
                    .id(1L)
                    .song(createTestSong(songId, artist))
                    .relatedSongRef(relatedSongRef)
                    .reason("같은 아티스트")
                    .displayOrder(0)
                    .build();

            given(relatedSongRepository.findBySongIdWithDetails(songId))
                    .willReturn(List.of(relatedSong));

            // when
            List<RelatedSongResponse> result = dailySongService.getRelatedSongs(songId);

            // then
            assertThat(result).hasSize(1);
            assertThat(result.get(0).reason()).isEqualTo("같은 아티스트");
            assertThat(result.get(0).id()).isEqualTo(2L);
        }
    }

    @Nested
    @DisplayName("getLikedSongs 메서드")
    class GetLikedSongsTest {

        @Test
        @DisplayName("좋아요한 곡 목록을 반환한다")
        void getLikedSongs_목록반환_성공() {
            // given
            Long memberId = 1L;
            Artist artist = createTestArtist();
            Song song = createTestSong(10L, artist);

            given(songLikeService.getLikedSongIds(memberId)).willReturn(List.of(10L));
            given(songRepository.findById(10L)).willReturn(Optional.of(song));
            given(songLikeService.getLikeCount(10L)).willReturn(5L);

            // when
            List<DailySongResponse> result = dailySongService.getLikedSongs(memberId);

            // then
            assertThat(result).hasSize(1);
            assertThat(result.get(0).id()).isEqualTo(10L);
            assertThat(result.get(0).isLiked()).isTrue();
            assertThat(result.get(0).likeCount()).isEqualTo(5L);
        }
    }

    @Nested
    @DisplayName("getSongById 메서드")
    class GetSongByIdTest {

        @Test
        @DisplayName("노래 상세 조회 시 연관곡이 포함된다")
        void getSongById_연관곡포함_성공() {
            // given
            Long songId = 1L;
            Long memberId = 1L;
            Artist artist = createTestArtist();
            Song song = createTestSong(songId, artist);
            Song relatedSongRef = createTestSong(2L, artist);

            RelatedSong relatedSong = RelatedSong.builder()
                    .id(1L)
                    .song(song)
                    .relatedSongRef(relatedSongRef)
                    .reason("비슷한 분위기")
                    .displayOrder(0)
                    .build();

            given(songRepository.findById(songId)).willReturn(Optional.of(song));
            given(relatedSongRepository.findBySongIdWithDetails(songId))
                    .willReturn(List.of(relatedSong));
            given(songLikeService.isLiked(memberId, songId)).willReturn(false);
            given(songLikeService.getLikeCount(songId)).willReturn(3L);

            // when
            DailySongResponse result = dailySongService.getSongById(songId, memberId);

            // then
            assertThat(result).isNotNull();
            assertThat(result.id()).isEqualTo(songId);
            assertThat(result.relatedSongs()).hasSize(1);
            assertThat(result.relatedSongs().get(0).reason()).isEqualTo("비슷한 분위기");
            assertThat(result.likeCount()).isEqualTo(3L);
        }
    }
}
