package com.hibi.server.domain.auth.dto;

import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.MemberStatus;
import com.hibi.server.domain.member.entity.ProviderType;
import com.hibi.server.domain.member.entity.UserRoleType;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

@DisplayName("CustomUserDetails 계정 상태 단위 테스트")
class CustomUserDetailsTest {

    private Member.MemberBuilder baseMember() {
        return Member.builder()
                .id(1L)
                .email("test@example.com")
                .password("encodedPassword")
                .nickname("테스트유저")
                .provider(ProviderType.NATIVE)
                .role(UserRoleType.USER)
                .status(MemberStatus.ACTIVE);
    }

    @Nested
    @DisplayName("isEnabled 메서드")
    class IsEnabledTest {

        @Test
        @DisplayName("활성 회원은 enabled 상태다")
        void 활성회원_enabled() {
            CustomUserDetails details = new CustomUserDetails(baseMember().build());
            assertThat(details.isEnabled()).isTrue();
        }

        @Test
        @DisplayName("탈퇴(soft-delete)한 회원은 disabled 상태다")
        void 탈퇴회원_disabled() {
            Member member = baseMember().deletedAt(LocalDateTime.now().minusDays(1)).build();
            CustomUserDetails details = new CustomUserDetails(member);
            assertThat(details.isEnabled()).isFalse();
        }
    }

    @Nested
    @DisplayName("isAccountNonLocked 메서드")
    class IsAccountNonLockedTest {

        @Test
        @DisplayName("활성 회원은 잠기지 않은 상태다")
        void 활성회원_잠금아님() {
            CustomUserDetails details = new CustomUserDetails(baseMember().build());
            assertThat(details.isAccountNonLocked()).isTrue();
        }

        @Test
        @DisplayName("영구 정지(BANNED)된 회원은 잠긴 상태다")
        void 밴회원_잠금() {
            Member member = baseMember().build();
            member.ban("커뮤니티 규칙 위반");
            CustomUserDetails details = new CustomUserDetails(member);
            assertThat(details.isAccountNonLocked()).isFalse();
        }

        @Test
        @DisplayName("정지 기간 중(SUSPENDED)인 회원은 잠긴 상태다")
        void 정지회원_잠금() {
            Member member = baseMember().build();
            member.suspend(LocalDateTime.now().plusDays(3), "부적절한 게시물");
            CustomUserDetails details = new CustomUserDetails(member);
            assertThat(details.isAccountNonLocked()).isFalse();
        }

        @Test
        @DisplayName("정지 기간이 만료된 회원은 잠기지 않은 상태다")
        void 정지만료회원_잠금아님() {
            Member member = baseMember().build();
            member.suspend(LocalDateTime.now().minusDays(1), "부적절한 게시물");
            CustomUserDetails details = new CustomUserDetails(member);
            assertThat(details.isAccountNonLocked()).isTrue();
        }
    }
}
