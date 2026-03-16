package com.hibi.server.domain.auth.repository;

import com.hibi.server.domain.auth.entity.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {

    // memberId와 현재 토큰 값으로 RefreshToken 조회 (정상적인 RTR 시도)
    Optional<RefreshToken> findByMemberIdAndTokenValueAndRevokedFalse(Long memberId, String tokenValue);

    // memberId와 이전 토큰 값으로 RefreshToken 조회 (Replay Attack 탐지)
    Optional<RefreshToken> findByMemberIdAndPreviousTokenValueAndRevokedFalse(Long memberId, String previousTokenValue);

    // 특정 memberId의 모든 유효한 RefreshToken 조회 (로그아웃, 비밀번호 변경 시)
    List<RefreshToken> findByMemberIdAndRevokedFalse(Long memberId);

    // 특정 memberId의 모든 RefreshToken 조회 (revoked 상태 무관)
    List<RefreshToken> findByMemberId(Long memberId);

    void deleteByExpiryDateBefore(LocalDateTime dateTime);
}
