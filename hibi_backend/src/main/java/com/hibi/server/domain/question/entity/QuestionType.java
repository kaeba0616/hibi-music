package com.hibi.server.domain.question.entity;

/**
 * 문의 유형 (F10)
 */
public enum QuestionType {
    ACCOUNT("계정"),
    SERVICE("서비스 이용"),
    BUG("버그 신고"),
    FEATURE("기능 제안"),
    OTHER("기타");

    private final String label;

    QuestionType(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    public static QuestionType fromString(String value) {
        if (value == null) {
            return OTHER;
        }
        try {
            return QuestionType.valueOf(value.toUpperCase());
        } catch (IllegalArgumentException e) {
            return OTHER;
        }
    }
}
