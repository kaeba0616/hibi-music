package com.hibi.server.global.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import lombok.RequiredArgsConstructor;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@OpenAPIDefinition(
        info = @Info(
                title = "Hibi API",
                description = "Hibi API 명세",
                version = "v1"
        ),
        security = @SecurityRequirement(name = "BearerAuth")
)
@SecurityScheme(
        name = "BearerAuth",
        type = SecuritySchemeType.HTTP,
        bearerFormat = "JWT",
        scheme = "bearer"
)
@Configuration
@RequiredArgsConstructor
public class SwaggerConfig {

    @Value("${api.version}")
    private String apiVersion;

    @Bean
    public GroupedOpenApi allApi() {
        return GroupedOpenApi.builder()
                .group("all")
                .pathsToMatch("/api/" + apiVersion + "/**")
                .build();
    }

    @Bean
    public GroupedOpenApi authApi() {
        return GroupedOpenApi.builder()
                .group("auth")
                .pathsToMatch("/api/" + apiVersion + "/auth/**")
                .build();
    }

    @Bean
    public GroupedOpenApi postApi() {
        return GroupedOpenApi.builder()
                .group("post")
                .pathsToMatch("/api/" + apiVersion + "/posts/**")
                .build();
    }

    @Bean
    public GroupedOpenApi songApi() {
        return GroupedOpenApi.builder()
                .group("song")
                .pathsToMatch("/api/" + apiVersion + "/songs/**")
                .build();
    }

    @Bean
    public GroupedOpenApi memberApi() {
        return GroupedOpenApi.builder()
                .group("member")
                .pathsToMatch("/api/" + apiVersion + "/members/**")
                .build();
    }

    @Bean
    public GroupedOpenApi artistApi() {
        return GroupedOpenApi.builder()
                .group("member")
                .pathsToMatch("/api/" + apiVersion + "/members/**")
                .build();
    }

}