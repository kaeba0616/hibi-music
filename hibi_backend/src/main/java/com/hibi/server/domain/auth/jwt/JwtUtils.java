package com.hibi.server.domain.auth.jwt;

import com.hibi.server.domain.auth.dto.CustomUserDetails;
import com.hibi.server.global.exception.AuthException;
import com.hibi.server.global.exception.ErrorCode;
import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.Map;

@Slf4j
@Component
public class JwtUtils {

    @Value("${jwt.secret}")
    private String jwtSecret;
    @Value("${jwt.expiration}")
    private int jwtExpiration;
    @Value("${jwt.refresh-expiration}")
    private int jwtRefreshExpiration;

    public LocalDateTime getRefreshTokenExpiryDate() {
        long expiryTimeMillis = new Date().getTime() + jwtRefreshExpiration;
        Date expiryDate = new Date(expiryTimeMillis);

        return expiryDate.toInstant()
                .atZone(ZoneId.systemDefault())
                .toLocalDateTime();
    }

    public String generateJwtToken(CustomUserDetails userPrincipal, int jwtExpirationMs) {
        Map<String, Object> claims = Jwts.claims().setSubject(userPrincipal.getUsername());
        claims.put("memberId", userPrincipal.getId());

        return Jwts.builder()
                .setClaims(claims) // Subject 대신 claims 맵 사용
                .setIssuedAt(new Date())
                .setExpiration(new Date((new Date()).getTime() + jwtExpirationMs))
                .signWith(key(), SignatureAlgorithm.HS256)
                .compact();
    }

    public String generateAccessToken(Authentication authentication) {
        CustomUserDetails userPrincipal = (CustomUserDetails) authentication.getPrincipal();
        return generateJwtToken(userPrincipal, jwtExpiration);
    }

    public String generateRefreshToken(Authentication authentication) {
        CustomUserDetails userPrincipal = (CustomUserDetails) authentication.getPrincipal();
        return generateJwtToken(userPrincipal, jwtRefreshExpiration);
    }

    private Key key() {
        return Keys.hmacShaKeyFor(Decoders.BASE64.decode(jwtSecret));
    }

    public String getEmailFromJwtToken(String token) {
        return Jwts.parserBuilder().setSigningKey(key()).build()
                .parseClaimsJws(token).getBody().getSubject();
    }

    public Long getMemberIdFromJwtToken(String token) {
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(key())
                .build()
                .parseClaimsJws(token)
                .getBody();
        return claims.get("memberId", Long.class);
    }

    public void validateJwtToken(String authToken) {
        try {
            Jwts.parserBuilder().setSigningKey(key()).build().parse(authToken);
        } catch (MalformedJwtException e) {
            log.error("Invalid JWT token: {}", e.getMessage());
            throw new AuthException(ErrorCode.JWT_INVALID_TOKEN);
        } catch (ExpiredJwtException e) {
            log.error("JWT token is expired: {}", e.getMessage());
            throw new AuthException(ErrorCode.JWT_EXPIRED_TOKEN);
        } catch (UnsupportedJwtException e) {
            log.error("JWT token is unsupported: {}", e.getMessage());
            throw new AuthException(ErrorCode.JWT_UNSUPPORTED_TOKEN);
        } catch (IllegalArgumentException e) {
            log.error("JWT claims string is empty: {}", e.getMessage());
            throw new AuthException(ErrorCode.JWT_MISSING_TOKEN);
        }
    }

}