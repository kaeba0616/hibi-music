package com.hibi.server.domain.report.entity;

/**
 * 신고 사유 Enum (F11)
 */
public enum ReportReason {
    SPAM("스팸/광고"),
    ABUSE("욕설/비방"),
    INAPPROPRIATE("불쾌한 내용"),
    COPYRIGHT("저작권 침해"),
    OTHER("기타");

    private final String displayName;

    ReportReason(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
