package com.hibi.server.domain.comment.service;

import com.hibi.server.domain.comment.dto.response.CommentResponse;
import com.hibi.server.domain.comment.entity.Comment;
import com.hibi.server.domain.comment.repository.CommentLikeRepository;
import com.hibi.server.domain.comment.repository.CommentRepository;
import com.hibi.server.domain.feedpost.entity.FeedPost;
import com.hibi.server.domain.feedpost.repository.FeedPostRepository;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.MemberStatus;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.support.ServiceTestSupport;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.BDDMockito.given;

@DisplayName("CommentService Top/Filter 단위 테스트")
class CommentTopFilterTest extends ServiceTestSupport {

    @Mock
    private CommentRepository commentRepository;

    @Mock
    private CommentLikeRepository commentLikeRepository;

    @Mock
    private FeedPostRepository feedPostRepository;

    @Mock
    private MemberRepository memberRepository;

    @InjectMocks
    private CommentService commentService;

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

    private FeedPost createTestPost(Long id, Member member) {
        return FeedPost.builder()
                .id(id)
                .member(member)
                .content("테스트 게시글")
                .likeCount(0)
                .commentCount(0)
                .build();
    }

    @Nested
    @DisplayName("getTopComments 메서드")
    class GetTopCommentsTest {

        @Test
        @DisplayName("좋아요 수 기준 상위 3개 댓글을 반환한다")
        void getTopComments_상위3개_반환() {
            // given
            Long postId = 1L;
            Long currentMemberId = 1L;
            Member member = createTestMember(1L);
            FeedPost feedPost = createTestPost(postId, member);

            Comment comment1 = Comment.builder()
                    .id(1L).feedPost(feedPost).member(member)
                    .content("인기 댓글 1").likeCount(10).isDeleted(false).isFiltered(false).build();
            Comment comment2 = Comment.builder()
                    .id(2L).feedPost(feedPost).member(member)
                    .content("인기 댓글 2").likeCount(8).isDeleted(false).isFiltered(false).build();
            Comment comment3 = Comment.builder()
                    .id(3L).feedPost(feedPost).member(member)
                    .content("인기 댓글 3").likeCount(5).isDeleted(false).isFiltered(false).build();
            Comment comment4 = Comment.builder()
                    .id(4L).feedPost(feedPost).member(member)
                    .content("인기 댓글 4").likeCount(3).isDeleted(false).isFiltered(false).build();

            given(commentRepository.findTopCommentsByFeedPostId(postId))
                    .willReturn(List.of(comment1, comment2, comment3, comment4));
            given(commentLikeRepository.findLikedCommentIdsByMemberIdAndCommentIds(eq(currentMemberId), anyList()))
                    .willReturn(List.of());

            // when
            List<CommentResponse> result = commentService.getTopComments(postId, currentMemberId);

            // then
            assertThat(result).hasSize(3);
            assertThat(result.get(0).content()).isEqualTo("인기 댓글 1");
            assertThat(result.get(1).content()).isEqualTo("인기 댓글 2");
            assertThat(result.get(2).content()).isEqualTo("인기 댓글 3");
        }
    }

    @Nested
    @DisplayName("필터링된 댓글")
    class FilteredCommentTest {

        @Test
        @DisplayName("필터링된 댓글은 isFiltered가 true이다")
        void filteredComment_isFiltered_true() {
            // given
            Member member = createTestMember(1L);
            FeedPost feedPost = createTestPost(1L, member);

            Comment filteredComment = Comment.builder()
                    .id(1L)
                    .feedPost(feedPost)
                    .member(member)
                    .content("부적절한 댓글")
                    .likeCount(0)
                    .isDeleted(false)
                    .isFiltered(false)
                    .build();

            // when
            filteredComment.markAsFiltered();

            // then
            assertThat(filteredComment.getIsFiltered()).isTrue();
            assertThat(filteredComment.getContent()).isEqualTo("부적절한 댓글");
        }
    }
}
