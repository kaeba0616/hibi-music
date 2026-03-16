package com.hibi.server.domain.auth.service;

import com.hibi.server.domain.auth.dto.CustomUserDetails;
import com.hibi.server.domain.auth.dto.response.ReissueResponse;
import com.hibi.server.domain.auth.entity.RefreshToken;
import com.hibi.server.domain.auth.jwt.JwtUtils;
import com.hibi.server.domain.auth.repository.RefreshTokenRepository;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class RefreshTokenService {

    private final RefreshTokenRepository refreshTokenRepository;
    private final MemberRepository memberRepository; // 사용자 정보 확인용 (필요하다면)
    private final JwtUtils jwtUtils;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public String createAndSaveRefreshToken(Long memberId, Authentication authentication) {
        List<RefreshToken> existingTokens = refreshTokenRepository.findByMemberId(memberId);
        existingTokens.forEach(RefreshToken::revoke);

        String newRefreshTokenValue = jwtUtils.generateRefreshToken(authentication);

        RefreshToken newRefreshToken = RefreshToken.of(
                memberRepository.findById(memberId)
                        .orElseThrow(() -> new CustomException(ErrorCode.BAD_CREDENTIALS)),
                newRefreshTokenValue,
                jwtUtils.getRefreshTokenExpiryDate(),
                LocalDateTime.now()
        );
        refreshTokenRepository.save(newRefreshToken);
        return newRefreshTokenValue;
    }

    @Transactional
    public ReissueResponse reissueTokens(String submittedRefreshToken) {
        jwtUtils.validateJwtToken(submittedRefreshToken);

        Long memberId = jwtUtils.getMemberIdFromJwtToken(submittedRefreshToken);
        if (memberId == null) {
            throw new CustomException(ErrorCode.AUTHENTICATION_FAILED);
        }

        Optional<RefreshToken> currentTokenRecordOpt = refreshTokenRepository
                .findByMemberIdAndTokenValueAndRevokedFalse(memberId, submittedRefreshToken);

        if (currentTokenRecordOpt.isPresent()) {
            RefreshToken currentTokenRecord = currentTokenRecordOpt.get();
            Member member = memberRepository.findById(memberId)
                    .orElseThrow(() -> new CustomException(ErrorCode.AUTHENTICATION_FAILED));

            CustomUserDetails userDetails = new CustomUserDetails(member);
            Authentication authentication = new UsernamePasswordAuthenticationToken(
                    userDetails,
                    null,
                    userDetails.getAuthorities()
            );

            String newAccessToken = jwtUtils.generateAccessToken(authentication);
            String newRefreshToken = jwtUtils.generateRefreshToken(authentication);

            currentTokenRecord.revoke();

            return ReissueResponse.of(newAccessToken, newRefreshToken);

        } else {
            Optional<RefreshToken> previousTokenRecordOpt = refreshTokenRepository.findByMemberIdAndPreviousTokenValueAndRevokedFalse(memberId, submittedRefreshToken);

            if (previousTokenRecordOpt.isPresent()) {
                List<RefreshToken> activeTokens = refreshTokenRepository.findByMemberIdAndRevokedFalse(memberId);
                activeTokens.forEach(RefreshToken::revoke);
                throw new CustomException(ErrorCode.REPLAY_ATTACK);
            } else {
                throw new CustomException(ErrorCode.JWT_INVALID_TOKEN);
            }
        }
    }

    @Transactional
    public void invalidateAllRefreshTokensForMember(Long memberId) {
        List<RefreshToken> activeTokens = refreshTokenRepository.findByMemberIdAndRevokedFalse(memberId);
        activeTokens.forEach(RefreshToken::revoke); // 각 토큰의 revoked 상태를 true로 변경
    }

    @Scheduled(cron = "0 0 4 * * ?")
    @Transactional
    public void cleanUpExpiredRefreshTokens() {
        refreshTokenRepository.deleteByExpiryDateBefore(LocalDateTime.now());
    }
}