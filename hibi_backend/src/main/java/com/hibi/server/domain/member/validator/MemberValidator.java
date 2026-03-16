package com.hibi.server.domain.member.validator;

import com.hibi.server.domain.member.repository.MemberRepository;
import com.hibi.server.global.exception.CustomException;
import com.hibi.server.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.regex.Pattern;

@Component
@RequiredArgsConstructor
public class MemberValidator {

    private static final Pattern PASSWORD_PATTERN =
            Pattern.compile("^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d@$!%*?&]{8,}$");
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private final MemberRepository memberRepository;

    public void validateEmail(String email) {
        if (email == null || email.isBlank()) {
            throw new CustomException(ErrorCode.EMAIL_REQUIRED);
        }

        if (!EMAIL_PATTERN.matcher(email).matches()) {
            throw new CustomException(ErrorCode.INVALID_EMAIL_FORMAT);
        }

        if (memberRepository.existsByEmailAndDeletedAtIsNull(email)) {
            throw new CustomException(ErrorCode.EMAIL_ALREADY_EXISTS);
        }
    }

    public void validatePassword(String password) {
        if (password == null || password.isBlank()) {
            throw new CustomException(ErrorCode.PASSWORD_REQUIRED);
        }

        if (!PASSWORD_PATTERN.matcher(password).matches()) {
            throw new CustomException(ErrorCode.INVALID_PASSWORD_PATTERN);
        }
    }

    public void validateNickname(String nickname, String currentNickname) {
        if (nickname == null || nickname.isBlank()) {
            throw new CustomException(ErrorCode.NICKNAME_REQUIRED);
        }

        if (nickname.length() < 2 || nickname.length() > 20) {
            throw new CustomException(ErrorCode.NICKNAME_INVALID_LENGTH);
        }

        if (!nickname.equals(currentNickname) && memberRepository.existsByNickname(nickname)) {
            throw new CustomException(ErrorCode.NICKNAME_ALREADY_EXISTS);
        }
    }
}
