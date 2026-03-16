package com.hibi.server.domain.member.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.SQLDelete;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Entity
@Table(name = "members")
@Builder
@SQLDelete(sql = "UPDATE members SET deleted_at = NOW() WHERE id = ?")
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @Column(name = "password", nullable = false)
    private String password;

    @Column(name = "nickname", nullable = false, unique = true, length = 20)
    private String nickname;

    @Enumerated(EnumType.STRING)
    @Column(name = "provider", nullable = false)
    private ProviderType provider;

    @Column(name = "provider_id")
    private String providerId;

    @Column(name = "profile_url", length = 512)
    private String profileUrl;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false)
    private UserRoleType role;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private MemberStatus status = MemberStatus.ACTIVE;

    @Column(name = "suspended_until")
    private LocalDateTime suspendedUntil;

    @Column(name = "suspended_reason", length = 300)
    private String suspendedReason;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;

    public static Member of(
            final String email,
            final String password,
            final String nickname,
            final ProviderType provider,
            final String providerId,
            final String profileUrl,
            final UserRoleType role) {
        return Member.builder()
                .email(email)
                .password(password)
                .nickname(nickname)
                .provider(provider)
                .providerId(providerId)
                .profileUrl(profileUrl)
                .role(role)
                .build();
    }

    public void updateNickname(@NotBlank String nickname) {
        this.nickname = nickname;
    }

    public void updatePasswordHash(@NotBlank String password) {
        this.password = password;
    }

    public void softDelete(LocalDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }

    public boolean isDeleted() { return this.deletedAt != null; }

    public void reactivateAccount(String encodedPassword, String nickname) {
        this.deletedAt = null;
        this.password = encodedPassword;
        this.nickname = nickname;
    }

    /**
     * 회원 정지 처리
     */
    public void suspend(LocalDateTime until, String reason) {
        this.status = MemberStatus.SUSPENDED;
        this.suspendedUntil = until;
        this.suspendedReason = reason;
    }

    /**
     * 회원 영구 정지(강제 탈퇴) 처리
     */
    public void ban(String reason) {
        this.status = MemberStatus.BANNED;
        this.suspendedUntil = null;
        this.suspendedReason = reason;
    }

    /**
     * 정지 해제
     */
    public void unban() {
        this.status = MemberStatus.ACTIVE;
        this.suspendedUntil = null;
        this.suspendedReason = null;
    }

    /**
     * 정지 상태 확인
     */
    public boolean isSuspended() {
        return this.status == MemberStatus.SUSPENDED;
    }

    /**
     * 강제 탈퇴 상태 확인
     */
    public boolean isBanned() {
        return this.status == MemberStatus.BANNED;
    }

    /**
     * 정지 만료 확인
     */
    public boolean isSuspensionExpired() {
        if (this.status != MemberStatus.SUSPENDED) {
            return false;
        }
        if (this.suspendedUntil == null) {
            return false; // 영구 정지
        }
        return LocalDateTime.now().isAfter(this.suspendedUntil);
    }
}