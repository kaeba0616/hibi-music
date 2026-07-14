package com.hibi.server.domain.member.service;

import com.hibi.server.domain.auth.service.RefreshTokenService;
import com.hibi.server.domain.comment.repository.CommentRepository;
import com.hibi.server.domain.member.dto.response.MemberProfileResponse;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.MemberStatus;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.member.validator.MemberValidator;
import com.hibi.server.support.ServiceTestSupport;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;
import static org.mockito.Mockito.never;

@DisplayName("MemberService 단위 테스트")
class MemberServiceTest extends ServiceTestSupport {

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

    private Member createTestMember(Long id, String nickname) {
        return Member.builder()
                .id(id)
                .email("user" + id + "@example.com")
                .password("encodedPassword")
                .nickname(nickname)
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.USER)
                .status(MemberStatus.ACTIVE)
                .build();
    }

    @Nested
    @DisplayName("getAllMembers 메서드")
    class GetAllMembersTest {

        @Test
        @DisplayName("탈퇴하지 않은 회원만 조회한다")
        void getAllMembers_탈퇴회원제외() {
            // given
            Member active = createTestMember(1L, "활성회원");
            given(memberRepository.findByDeletedAtIsNull()).willReturn(List.of(active));

            // when
            List<MemberProfileResponse> result = memberService.getAllMembers();

            // then
            assertThat(result).hasSize(1);
            assertThat(result.get(0).nickname()).isEqualTo("활성회원");
            then(memberRepository).should(never()).findAll();
        }
    }

    @Nested
    @DisplayName("getMyComments 메서드")
    class GetMyCommentsTest {

        @Test
        @DisplayName("삭제된 댓글은 DB 쿼리에서 제외한다")
        void getMyComments_삭제댓글_DB필터() {
            // given
            given(commentRepository.findByMemberIdAndIsDeletedFalseOrderByCreatedAtDesc(1L))
                    .willReturn(List.of());

            // when
            var result = memberService.getMyComments(1L);

            // then
            assertThat(result).isEmpty();
            then(commentRepository).should(never()).findByMemberIdOrderByCreatedAtDesc(1L);
        }
    }
}
