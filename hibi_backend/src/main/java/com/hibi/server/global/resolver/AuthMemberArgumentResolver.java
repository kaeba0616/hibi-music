package com.hibi.server.global.resolver;

import com.hibi.server.domain.auth.dto.CustomUserDetails;
import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.global.annotation.AuthMember;
import org.springframework.core.MethodParameter;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

@Component
public class AuthMemberArgumentResolver implements HandlerMethodArgumentResolver {

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        boolean hasAuthMemberAnnotation = parameter.hasParameterAnnotation(AuthMember.class);
        Class<?> parameterType = parameter.getParameterType();
        // CustomUserDetails 또는 Member 타입 모두 지원
        boolean isSupported = CustomUserDetails.class.isAssignableFrom(parameterType)
                || Member.class.isAssignableFrom(parameterType);
        return hasAuthMemberAnnotation && isSupported;
    }

    @Override
    public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer, NativeWebRequest webRequest, WebDataBinderFactory binderFactory) throws Exception {
        AuthMember authMember = parameter.getParameterAnnotation(AuthMember.class);
        boolean required = authMember != null && authMember.required();

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        // 비인증 사용자 처리
        if (authentication == null || "anonymousUser".equals(authentication.getPrincipal())) {
            if (required) {
                throw new AccessDeniedException("접근 권한이 없습니다. 로그인 후 이용해주세요.");
            }
            return null; // optional인 경우 null 반환
        }

        Object principal = authentication.getPrincipal();
        if (!(principal instanceof CustomUserDetails customUserDetails)) {
            if (required) {
                throw new AccessDeniedException("잘못된 인증 주체 정보입니다.");
            }
            return null;
        }

        // 파라미터 타입에 따라 적절한 객체 반환
        Class<?> parameterType = parameter.getParameterType();
        if (Member.class.isAssignableFrom(parameterType)) {
            return customUserDetails.getMember();
        }
        return customUserDetails;
    }
}
