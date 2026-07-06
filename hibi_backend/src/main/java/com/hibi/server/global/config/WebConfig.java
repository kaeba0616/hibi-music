package com.hibi.server.global.config;

import com.hibi.server.global.resolver.AuthMemberArgumentResolver;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.List;

@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {
    private final AuthMemberArgumentResolver authMemberArgumentResolver;

    @Override
    public void addArgumentResolvers(List<HandlerMethodArgumentResolver> argumentResolvers) {
        argumentResolvers.add(authMemberArgumentResolver);
    }

    // CORS 설정은 SecurityConfig의 CorsConfigurationSource에서 단일 관리한다
}
