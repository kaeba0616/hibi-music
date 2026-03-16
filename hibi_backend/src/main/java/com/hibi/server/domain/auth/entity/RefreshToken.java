package com.hibi.server.domain.auth.entity;


import com.hibi.server.domain.member.entity.Member;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "refresh_tokens")
@Getter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
public class RefreshToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Column(name = "token_value", nullable = false, unique = true, length = 500)
    private String tokenValue;

    @Column(name = "previous_token_value", unique = true, length = 500)
    private String previousTokenValue;

    @Column(name = "expiry_date", nullable = false)
    private LocalDateTime expiryDate;

    @Column(name = "issued_at", nullable = false)
    private LocalDateTime issuedAt;

    @Column(name = "revoked", nullable = false)
    private boolean revoked;

    public static RefreshToken of(Member member, String tokenValue, LocalDateTime expiryDate, LocalDateTime issuedAt) {
        return RefreshToken.builder()
                .member(member)
                .tokenValue(tokenValue)
                .previousTokenValue(null)
                .expiryDate(expiryDate)
                .issuedAt(issuedAt)
                .revoked(false)
                .build();
    }

    public void revoke() {
        this.revoked = true;
    }

    public void updateToken(String newTokenValue, String oldTokenValue, LocalDateTime newExpiryDate, LocalDateTime newIssuedAt) {
        this.tokenValue = newTokenValue;
        this.previousTokenValue = oldTokenValue;
        this.expiryDate = newExpiryDate;
        this.issuedAt = newIssuedAt;
    }


}
