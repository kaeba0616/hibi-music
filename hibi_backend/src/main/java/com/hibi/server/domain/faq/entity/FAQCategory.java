package com.hibi.server.domain.faq.entity;

/**
 * FAQ 카테고리
 */
public enum FAQCategory {
    ACCOUNT("계정"),
    SERVICE("서비스 이용"),
    COMMUNITY("커뮤니티"),
    OTHER("기타");

    private final String label;

    FAQCategory(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    public static FAQCategory fromString(String value) {
        if (value == null) {
            return OTHER;
        }
        try {
            return FAQCategory.valueOf(value.toUpperCase());
        } catch (IllegalArgumentException e) {
            return OTHER;
        }
    }
}
