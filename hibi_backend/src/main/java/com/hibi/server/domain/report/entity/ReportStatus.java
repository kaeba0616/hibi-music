package com.hibi.server.domain.report.entity;

/**
 * 신고 처리 상태 Enum (F11)
 */
public enum ReportStatus {
    PENDING("대기중"),
    REVIEWED("검토됨"),
    RESOLVED("처리완료"),
    DISMISSED("기각");

    private final String displayName;

    ReportStatus(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
