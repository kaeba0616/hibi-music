package com.hibi.server.domain.question.entity;

/**
 * 문의 상태 (F10)
 */
public enum QuestionStatus {
    RECEIVED("접수됨"),
    PROCESSING("처리중"),
    ANSWERED("답변완료");

    private final String label;

    QuestionStatus(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    public static QuestionStatus fromString(String value) {
        if (value == null) {
            return RECEIVED;
        }
        try {
            return QuestionStatus.valueOf(value.toUpperCase());
        } catch (IllegalArgumentException e) {
            return RECEIVED;
        }
    }
}
