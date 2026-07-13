package com.hibi.server.domain.comment.repository;

import com.hibi.server.domain.comment.entity.Comment;
import com.hibi.server.domain.feedpost.entity.FeedPost;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.MemberStatus;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import com.hibi.server.support.RepositoryTestSupport;
import org.hibernate.Hibernate;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DisplayName("CommentRepository 테스트")
class CommentRepositoryTest extends RepositoryTestSupport {

    @Autowired
    private CommentRepository commentRepository;

    @Autowired
    private TestEntityManager em;

    private FeedPost feedPost;

    @BeforeEach
    void setUp() {
        Member member = em.persist(Member.builder()
                .email("writer@example.com")
                .password("encodedPassword")
                .nickname("작성자")
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.USER)
                .status(MemberStatus.ACTIVE)
                .build());

        feedPost = em.persist(FeedPost.builder()
                .member(member)
                .content("게시글")
                .likeCount(0)
                .commentCount(0)
                .build());

        Comment parent1 = em.persist(Comment.of(feedPost, member, "첫 번째 댓글"));
        em.persist(Comment.ofReply(feedPost, member, "첫 번째 대댓글", parent1));
        em.persist(Comment.ofReply(feedPost, member, "두 번째 대댓글", parent1));
        em.persist(Comment.of(feedPost, member, "두 번째 댓글"));

        em.flush();
        em.clear();
    }

    @Test
    @DisplayName("최상위 댓글 조회 시 작성자와 대댓글이 fetch join으로 함께 로딩된다")
    void findTopLevelComments_연관엔티티_즉시로딩() {
        // when
        List<Comment> comments = commentRepository.findTopLevelCommentsByFeedPostId(feedPost.getId());

        // then
        assertThat(comments).hasSize(2);
        for (Comment comment : comments) {
            assertThat(Hibernate.isInitialized(comment.getMember()))
                    .as("댓글 작성자는 fetch join으로 로딩되어야 한다")
                    .isTrue();
            assertThat(Hibernate.isInitialized(comment.getReplies()))
                    .as("대댓글 목록은 fetch join으로 로딩되어야 한다")
                    .isTrue();
        }
    }

    @Test
    @DisplayName("최상위 댓글과 대댓글은 작성일 오름차순으로 정렬된다")
    void findTopLevelComments_정렬() {
        // when
        List<Comment> comments = commentRepository.findTopLevelCommentsByFeedPostId(feedPost.getId());

        // then
        assertThat(comments).extracting(Comment::getContent)
                .containsExactly("첫 번째 댓글", "두 번째 댓글");
        assertThat(comments.get(0).getReplies()).extracting(Comment::getContent)
                .containsExactly("첫 번째 대댓글", "두 번째 대댓글");
        assertThat(comments.get(1).getReplies()).isEmpty();
    }
}
