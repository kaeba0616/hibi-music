package com.hibi.server.domain.auth.jwt;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Slf4j
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtils jwtUtils;
    private final UserDetailsService userDetailsService;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        // OPTIONS 요청은 인증 필터를 건너뜀
        return "OPTIONS".equalsIgnoreCase(request.getMethod());
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String jwt = parseJwt(request);

        if (jwt != null) {
            try {
                jwtUtils.validateJwtToken(jwt);

                String username = jwtUtils.getEmailFromJwtToken(jwt);
                UserDetails userDetails = userDetailsService.loadUserByUsername(username);

                // 탈퇴/정지/영구정지 계정은 유효한 토큰을 갖고 있어도 인증을 부여하지 않는다
                if (userDetails.isEnabled() && userDetails.isAccountNonLocked()) {
                    UsernamePasswordAuthenticationToken authentication =
                            new UsernamePasswordAuthenticationToken(
                                    userDetails,
                                    null,
                                    userDetails.getAuthorities());
                    authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                } else {
                    log.warn("비활성/잠금 계정의 토큰 인증 시도 차단: {}", username);
                }
            } catch (Exception e) {
                // 만료/위조 토큰은 미인증 상태로 체인을 계속 진행한다.
                // 보호된 엔드포인트는 EntryPoint가 401을 반환하고, 공개 엔드포인트는 정상 동작한다.
                SecurityContextHolder.clearContext();
                log.debug("JWT 인증 실패, 미인증으로 진행: {}", e.getMessage());
            }
        }
        filterChain.doFilter(request, response);
    }

    //TODO : JwtUtils로 옮기기
    private String parseJwt(HttpServletRequest request) {
        String headerAuth = request.getHeader("Authorization");
        log.info("Authorization header: {}", headerAuth);
        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            return headerAuth.substring(7);
        }

        return null;
    }

}


