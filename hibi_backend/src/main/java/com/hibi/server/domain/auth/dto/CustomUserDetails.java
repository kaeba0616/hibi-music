package com.hibi.server.domain.auth.dto;

import com.hibi.server.domain.member.entity.Member;
import com.hibi.server.domain.member.entity.UserRoleType;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

@Getter
public class CustomUserDetails implements UserDetails {

    private final Long id;
    private final String email;
    private final String password;
    private final UserRoleType role;
    private final Member member;

    public CustomUserDetails(Member member) {
        this.id = member.getId();
        this.email = member.getEmail();
        this.password = member.getPassword();
        this.role = member.getRole();
        this.member = member;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singleton(() -> "ROLE_" + role.name());
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public String getPassword() {
        return password;
    }

    /**
     * 탈퇴(soft-delete)한 계정은 비활성 처리한다.
     */
    @Override
    public boolean isEnabled() {
        return !member.isDeleted();
    }

    /**
     * 영구 정지(BANNED) 또는 정지 기간이 남은(SUSPENDED) 계정은 잠금 처리한다.
     */
    @Override
    public boolean isAccountNonLocked() {
        if (member.isBanned()) {
            return false;
        }
        if (member.isSuspended()) {
            return member.isSuspensionExpired();
        }
        return true;
    }
}

