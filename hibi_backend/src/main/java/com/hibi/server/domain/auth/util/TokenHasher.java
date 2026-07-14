package com.hibi.server.domain.auth.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;

/**
 * 리프레시 토큰 해시 유틸.
 * DB에는 평문 대신 SHA-256 해시를 저장하고, 조회 시 제출된 토큰을 해시하여 대조한다.
 * (JWT는 엔트로피가 충분히 높아 결정적 해시로도 안전하며, 값 조회가 가능해야 하므로 salt를 쓰지 않는다)
 */
public final class TokenHasher {

    private TokenHasher() {
    }

    public static String sha256(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 알고리즘을 사용할 수 없습니다", e);
        }
    }
}
