package com.hibi.server.domain.feedpost.dto.response;

import com.hibi.server.domain.comment.dto.response.CommentAuthorResponse;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.MemberStatus;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

@DisplayName("작성자 응답 DTO - 탈퇴 회원 마스킹 테스트")
class AuthorResponseTest {

    private Member createMember() {
        return Member.builder()
                .id(1L)
                .email("secret@example.com")
                .password("encodedPassword")
                .nickname("원래닉네임")
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.USER)
                .status(MemberStatus.ACTIVE)
                .build();
    }

    @Nested
    @DisplayName("FeedPostAuthorResponse")
    class FeedPostAuthorTest {

        @Test
        @DisplayName("활성 회원은 닉네임과 username이 그대로 노출된다")
        void from_활성회원() {
            Member member = createMember();

            FeedPostAuthorResponse response = FeedPostAuthorResponse.from(member);

            assertThat(response.nickname()).isEqualTo("원래닉네임");
            assertThat(response.username()).isEqualTo("secret");
        }

        @Test
        @DisplayName("탈퇴 회원은 닉네임/이메일이 마스킹된다")
        void from_탈퇴회원_마스킹() {
            Member member = createMember();
            member.softDelete(LocalDateTime.now());

            FeedPostAuthorResponse response = FeedPostAuthorResponse.from(member);

            assertThat(response.nickname()).isEqualTo("탈퇴한 사용자");
            assertThat(response.username()).isEmpty();
            assertThat(response.profileImage()).isNull();
        }
    }

    @Nested
    @DisplayName("CommentAuthorResponse")
    class CommentAuthorTest {

        @Test
        @DisplayName("탈퇴 회원은 닉네임/이메일이 마스킹된다")
        void from_탈퇴회원_마스킹() {
            Member member = createMember();
            member.softDelete(LocalDateTime.now());

            CommentAuthorResponse response = CommentAuthorResponse.from(member);

            assertThat(response.nickname()).isEqualTo("탈퇴한 사용자");
            assertThat(response.username()).isEmpty();
            assertThat(response.profileImage()).isNull();
        }
    }
}
