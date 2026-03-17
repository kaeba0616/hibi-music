package com.hibi.server.domain.admin.service;

import com.hibi.server.domain.admin.dto.request.AdminSongCreateRequest;
import com.hibi.server.domain.admin.dto.request.SchedulePublishRequest;
import com.hibi.server.domain.admin.dto.response.AdminCommentListResponse;
import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.domain.artist.repository.ArtistRepository;
import com.hibi.server.domain.comment.entity.Comment;
import com.hibi.server.domain.comment.repository.CommentRepository;
import com.hibi.server.domain.faq.repository.FAQRepository;
import com.hibi.server.domain.feedpost.entity.FeedPost;
import com.hibi.server.domain.feedpost.repository.FeedPostRepository;
import com.hibi.server.domain.follow.repository.MemberFollowRepository;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.MemberStatus;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.question.repository.QuestionRepository;
import com.hibi.server.domain.report.entity.ReportTargetType;
import com.hibi.server.domain.report.repository.ReportRepository;
import com.hibi.server.domain.song.entity.RelatedSong;
import com.hibi.server.domain.song.entity.Song;
import com.hibi.server.domain.song.repository.RelatedSongRepository;
import com.hibi.server.domain.song.repository.SongRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import com.hibi.server.support.ServiceTestSupport;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;
import static org.mockito.Mockito.times;

@DisplayName("AdminService 곡 등록/예약/댓글 관리 단위 테스트")
class AdminSongAndScheduleTest extends ServiceTestSupport {

    @Mock
    private MemberRepository memberRepository;

    @Mock
    private ReportRepository reportRepository;

    @Mock
    private QuestionRepository questionRepository;

    @Mock
    private FAQRepository faqRepository;

    @Mock
    private FeedPostRepository feedPostRepository;

    @Mock
    private CommentRepository commentRepository;

    @Mock
    private MemberFollowRepository memberFollowRepository;

    @Mock
    private SongRepository songRepository;

    @Mock
    private ArtistRepository artistRepository;

    @Mock
    private RelatedSongRepository relatedSongRepository;

    @InjectMocks
    private AdminService adminService;

    private Member createTestMember(Long id) {
        return Member.builder()
                .id(id)
                .email("user" + id + "@example.com")
                .password("encodedPassword")
                .nickname("유저" + id)
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.USER)
                .status(MemberStatus.ACTIVE)
                .build();
    }

    @Nested
    @DisplayName("createAdminSong 메서드")
    class CreateAdminSongTest {

        @Test
        @DisplayName("연관곡 포함 곡 등록이 성공한다")
        void createAdminSong_연관곡포함_성공() {
            // given
            Artist artist = Artist.builder()
                    .id(1L).nameKor("아티스트").nameJp("アーティスト").build();
            Song relatedSongRef = Song.builder()
                    .id(10L).titleKor("연관곡").titleJp("関連曲").artist(artist).build();

            AdminSongCreateRequest.RelatedSongInput relatedInput =
                    new AdminSongCreateRequest.RelatedSongInput(10L, "같은 아티스트");
            AdminSongCreateRequest request = new AdminSongCreateRequest(
                    "새 곡", "New Song", "新曲", 1L,
                    "곡 소개", "日本語歌詞", "한국어 가사",
                    "https://youtube.com/watch?v=test",
                    List.of(relatedInput)
            );

            Song savedSong = Song.builder()
                    .id(100L).titleKor("새 곡").titleJp("新曲").artist(artist).build();

            given(artistRepository.findById(1L)).willReturn(Optional.of(artist));
            given(songRepository.save(any(Song.class))).willReturn(savedSong);
            given(songRepository.findById(10L)).willReturn(Optional.of(relatedSongRef));
            given(relatedSongRepository.save(any(RelatedSong.class)))
                    .willReturn(RelatedSong.of(savedSong, relatedSongRef, "같은 아티스트"));

            // when
            adminService.createAdminSong(request);

            // then
            then(songRepository).should(times(1)).save(any(Song.class));
            then(relatedSongRepository).should(times(1)).save(any(RelatedSong.class));
        }
    }

    @Nested
    @DisplayName("scheduleSongPublish 메서드")
    class ScheduleSongPublishTest {

        @Test
        @DisplayName("예약 게시를 설정한다")
        void scheduleSongPublish_성공() {
            // given
            Long songId = 1L;
            Artist artist = Artist.builder()
                    .id(1L).nameKor("아티스트").nameJp("アーティスト").build();
            Song song = Song.builder()
                    .id(songId).titleKor("곡 제목").titleJp("曲タイトル").artist(artist).build();
            LocalDateTime scheduledAt = LocalDateTime.now().plusDays(7);
            SchedulePublishRequest request = new SchedulePublishRequest(songId, scheduledAt);

            given(songRepository.findById(songId)).willReturn(Optional.of(song));

            // when
            adminService.scheduleSongPublish(songId, request);

            // then
            assertThat(song.getScheduledPublishAt()).isEqualTo(scheduledAt);
            then(songRepository).should(times(1)).save(song);
        }
    }

    @Nested
    @DisplayName("getAdminComments 메서드")
    class GetAdminCommentsTest {

        @Test
        @DisplayName("관리자 댓글 목록을 페이징하여 반환한다")
        void getAdminComments_페이징_성공() {
            // given
            Member member = createTestMember(1L);
            FeedPost feedPost = FeedPost.builder()
                    .id(1L).member(member).content("게시글")
                    .likeCount(0).commentCount(1).build();
            Comment comment = Comment.builder()
                    .id(1L).feedPost(feedPost).member(member)
                    .content("댓글 내용").likeCount(0).isDeleted(false).isFiltered(false).build();

            Page<Comment> commentPage = new PageImpl<>(List.of(comment));
            given(commentRepository.findAll(any(Pageable.class))).willReturn(commentPage);
            given(reportRepository.countByTargetTypeAndTargetId(eq(ReportTargetType.COMMENT), eq(1L)))
                    .willReturn(0L);

            // when
            AdminCommentListResponse result = adminService.getAdminComments(false, 0, 20);

            // then
            assertThat(result).isNotNull();
            assertThat(result.comments()).hasSize(1);
            assertThat(result.comments().get(0).content()).isEqualTo("댓글 내용");
        }
    }

    @Nested
    @DisplayName("deleteAdminComment 메서드")
    class DeleteAdminCommentTest {

        @Test
        @DisplayName("관리자가 댓글을 삭제한다")
        void deleteAdminComment_성공() {
            // given
            Long commentId = 1L;
            Member member = createTestMember(1L);
            FeedPost feedPost = FeedPost.builder()
                    .id(1L).member(member).content("게시글")
                    .likeCount(0).commentCount(1).build();
            Comment comment = Comment.builder()
                    .id(commentId).feedPost(feedPost).member(member)
                    .content("삭제할 댓글").likeCount(0).isDeleted(false).isFiltered(false).build();

            given(commentRepository.findById(commentId)).willReturn(Optional.of(comment));

            // when
            adminService.deleteAdminComment(commentId);

            // then
            then(commentRepository).should(times(1)).delete(comment);
        }
    }
}
