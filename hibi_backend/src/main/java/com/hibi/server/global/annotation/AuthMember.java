package com.hibi.server.global.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.PARAMETER)
@Retention(RetentionPolicy.RUNTIME)
public @interface AuthMember {
    /**
     * 인증 필수 여부. false인 경우 비인증 사용자는 null을 반환합니다.
     */
    boolean required() default false;
}
