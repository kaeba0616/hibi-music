package com.hibi.server.domain.member.service;

import com.hibi.server.domain.comment.entity.Comment;
import com.hibi.server.domain.comment.repository.CommentRepository;
import com.hibi.server.domain.feedpost.entity.FeedPost;
import com.hibi.server.domain.member.dto.response.MyCommentResponse;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.MemberStatus;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.member.validator.MemberValidator;
import com.hibi.server.domain.auth.service.RefreshTokenService;
import com.hibi.server.domain.question.dto.request.QuestionCreateRequest;
import com.hibi.server.domain.question.entity.Question;
import com.hibi.server.domain.question.entity.QuestionType;
import com.hibi.server.domain.question.repository.QuestionRepository;
import com.hibi.server.domain.question.service.QuestionService;
import com.hibi.server.domain.song.entity.Song;
import com.hibi.server.domain.artist.entity.Artist;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import com.hibi.server.support.ServiceTestSupport;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;

@DisplayName("MemberService/QuestionService 내 댓글 & 문의 제한 단위 테스트")
class MyCommentsAndQuestionLimitTest extends ServiceTestSupport {

    // MemberService 의존성
    @Mock
    private MemberRepository memberRepository;

    @Mock
    private CommentRepository commentRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private RefreshTokenService refreshTokenService;

    @Mock
    private MemberValidator memberValidator;

    @InjectMocks
    private MemberService memberService;

    // QuestionService 의존성
    @Mock
    private QuestionRepository questionRepository;

    @Mock
    private MemberRepository memberRepository2;

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
    @DisplayName("getMyComments 메서드")
    class GetMyCommentsTest {

        @Test
        @DisplayName("회원의 댓글 목록을 반환한다")
        void getMyComments_목록반환_성공() {
            // given
            Long memberId = 1L;
            Member member = createTestMember(memberId);
            Artist artist = Artist.builder()
                    .id(1L).nameKor("아티스트").build();
            Song song = Song.builder()
                    .id(1L).titleKor("노래").titleJp("曲").artist(artist).build();
            FeedPost feedPost = FeedPost.builder()
                    .id(1L).member(member).content("게시글").taggedSong(song)
                    .likeCount(0).commentCount(1).build();

            Comment comment = Comment.builder()
                    .id(1L).feedPost(feedPost).member(member)
                    .content("내 댓글").likeCount(2).isDeleted(false).build();

            given(commentRepository.findByMemberIdOrderByCreatedAtDesc(memberId))
                    .willReturn(List.of(comment));

            // when
            List<MyCommentResponse> result = memberService.getMyComments(memberId);

            // then
            assertThat(result).hasSize(1);
            assertThat(result.get(0).content()).isEqualTo("내 댓글");
            assertThat(result.get(0).songTitle()).isEqualTo("曲");
            assertThat(result.get(0).artistName()).isEqualTo("아티스트");
        }
    }

    @Nested
    @DisplayName("QuestionService - getTodayQuestionCount 메서드")
    class GetTodayQuestionCountTest {

        @Test
        @DisplayName("오늘의 문의 작성 수를 반환한다")
        void getTodayQuestionCount_반환_성공() {
            // given
            Long memberId = 1L;
            QuestionService questionService = new QuestionService(questionRepository, memberRepository);

            given(questionRepository.countTodayQuestionsByMemberId(eq(memberId), any(LocalDateTime.class)))
                    .willReturn(2L);

            // when
            long count = questionService.getTodayQuestionCount(memberId);

            // then
            assertThat(count).isEqualTo(2L);
        }
    }

    @Nested
    @DisplayName("QuestionService - createQuestion 일일 제한")
    class CreateQuestionLimitTest {

        @Test
        @DisplayName("일일 문의 3개 초과 시 예외가 발생한다")
        void createQuestion_일일제한초과_예외() {
            // given
            Long memberId = 1L;
            Member member = createTestMember(memberId);
            QuestionService questionService = new QuestionService(questionRepository, memberRepository);

            QuestionCreateRequest request = new QuestionCreateRequest("BUG", "버그 제목", "버그 내용 상세 설명입니다");

            given(memberRepository.findById(memberId)).willReturn(Optional.of(member));
            given(questionRepository.countTodayQuestionsByMemberId(eq(memberId), any(LocalDateTime.class)))
                    .willReturn(3L);

            // when & then
            assertThatThrownBy(() -> questionService.createQuestion(request, memberId))
                    .isInstanceOf(CustomException.class)
                    .satisfies(ex -> {
                        CustomException customEx = (CustomException) ex;
                        assertThat(customEx.getErrorCode()).isEqualTo(ErrorCode.DAILY_QUESTION_LIMIT_EXCEEDED);
                    });
        }
    }
}
