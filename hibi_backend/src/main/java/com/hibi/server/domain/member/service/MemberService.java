package com.hibi.server.domain.member.service;

import com.hibi.server.domain.auth.service.RefreshTokenService;
import com.hibi.server.domain.member.dto.request.MemberUpdateRequest;
import com.hibi.server.domain.member.dto.response.MemberProfileResponse;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.domain.member.validator.MemberValidator;
import com.hibi.server.global.exception.CustomException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import static com.hibi.server.global.exception.ErrorCode.ENTITY_NOT_FOUND;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberService {

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final RefreshTokenService refreshTokenService;
    private final MemberValidator memberValidator;

    public MemberProfileResponse getMyProfileById(long id) {
        return memberRepository.findByIdAndDeletedAtIsNull(id)
                .map(MemberProfileResponse::from)
                .orElseThrow(() -> new CustomException(ENTITY_NOT_FOUND));
    }

    public MemberProfileResponse getMemberProfileById(long id) {
        return memberRepository.findByIdAndDeletedAtIsNull(id)
                .map(member -> MemberProfileResponse.of(member.getNickname()))
                .orElseThrow(() -> new CustomException(ENTITY_NOT_FOUND));
    }

    @Transactional
    public MemberProfileResponse updateMemberInfo(long memberId, MemberUpdateRequest request) {
        Member member = memberRepository.findByIdAndDeletedAtIsNull(memberId)
                .orElseThrow(() -> new CustomException(ENTITY_NOT_FOUND));

        String nickname = request.nickname();
        String password = request.password();

        memberValidator.validateNickname(nickname, member.getNickname());
        memberValidator.validatePassword(password);

        if (!member.getNickname().equals(nickname)) {
            member.updateNickname(nickname);
        }

        String encodedNewPassword = passwordEncoder.encode(password);
        member.updatePasswordHash(encodedNewPassword);

        return MemberProfileResponse.from(member);
    }

    @Transactional
    public void withdrawMember(long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ENTITY_NOT_FOUND));
        member.softDelete(LocalDateTime.now());
        refreshTokenService.invalidateAllRefreshTokensForMember(memberId);
    }

    public List<MemberProfileResponse> getAllMembers() {
        return memberRepository.findAll().stream()
                .map(MemberProfileResponse::from)
                .collect(Collectors.toList());
    }
}