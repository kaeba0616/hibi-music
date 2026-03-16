package com.hibi.server.domain.report.entity;

/**
 * 신고 대상 유형 Enum (F11)
 */
public enum ReportTargetType {
    POST("게시글"),
    COMMENT("댓글"),
    MEMBER("사용자");

    private final String displayName;

    ReportTargetType(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
