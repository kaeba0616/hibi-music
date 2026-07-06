package com.hibi.server.domain.auth.config;

import com.hibi.server.domain.auth.jwt.AuthEntryPointHandler;
import com.hibi.server.domain.auth.jwt.JwtAuthenticationFilter;
import com.hibi.server.domain.auth.jwt.JwtUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final AuthEntryPointHandler unauthorizedHandler;
    private final JwtUtils jwtUtils;
    private final UserDetailsService userDetailsService;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter() {
        return new JwtAuthenticationFilter(jwtUtils, userDetailsService);
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())
                .exceptionHandling(exception -> exception.authenticationEntryPoint(unauthorizedHandler))
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // 로그아웃은 본인 인증 필수 (permitAll인 /auth/** 보다 먼저 매칭되어야 함)
                        .requestMatchers("/api/v1/auth/sign-out").authenticated()

                        // 인증 관련 (Public)
                        .requestMatchers("/api/v1/auth/**").permitAll()

                        // 콘텐츠 조회 - GET만 Public
                        .requestMatchers(HttpMethod.GET, "/api/v1/daily-songs/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/v1/artists/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/v1/faqs/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/v1/search").permitAll()

                        // 사용자 프로필 조회 - GET만 Public
                        .requestMatchers(HttpMethod.GET, "/api/v1/users/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/v1/members/info/**").permitAll()

                        // 게시글/댓글 조회 - 팔로잉 피드는 인증 필요, 나머지 GET은 Public
                        .requestMatchers(HttpMethod.GET, "/api/v1/posts/following").authenticated()
                        .requestMatchers(HttpMethod.GET, "/api/v1/posts/**").permitAll()

                        // Swagger UI
                        .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()

                        // 그 외 모든 요청은 인증 필요
                        .anyRequest().authenticated())
                .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    /**
     * CORS 설정. 와일드카드 + allowCredentials 조합은 브라우저 동일 출처 보호를 무력화하므로
     * 허용 출처를 프로퍼티(cors.allowed-origins)로 명시한다.
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource(
            @Value("${cors.allowed-origins}") List<String> allowedOrigins) {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(allowedOrigins);
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("Authorization", "Content-Type"));
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

}
