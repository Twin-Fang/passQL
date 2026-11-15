package com.passql.question.constant;

import java.util.Locale;

/**
 * 문제 내부 관리 태그 네임스페이스 (태그 `네임스페이스:값` 의 앞부분, 관리자 화면 묶음 순서 = 선언 순서)
 * 목록에 없는 네임스페이스·네임스페이스 없는 태그(new-type 등)도 허용 > 관리자 화면 "기타" 묶음
 */
public enum QuestionInternalTagNamespace {
    SOURCE("source", "출처", false),    // 파생 출처 문항: source:{회차}-{실번호} 예 source:63-17
    TREND("trend", "유형", true),       // 경향 카탈로그 템플릿: trend:t41 (화면 표시 T41)
    ROUND("round", "회차", false),      // 근거 시험 회차: round:63
    BATCH("batch", "묶음", false),      // 원본 YAML 파일 묶음: batch:batch06
    CONCEPT("concept", "개념", false);  // 핵심 개념: concept:비등가조인

    // 네임스페이스와 값 구분자
    public static final String SEPARATOR = ":";

    private final String prefix;
    private final String label;
    // 관리자 화면 값 대문자 표시 (저장값은 소문자, 카탈로그 id 표기 T41 에 맞춤)
    private final boolean isDisplayedInUppercase;

    QuestionInternalTagNamespace(String prefix, String label, boolean isDisplayedInUppercase) {
        this.prefix = prefix;
        this.label = label;
        this.isDisplayedInUppercase = isDisplayedInUppercase;
    }

    public String getPrefix() {
        return prefix;
    }

    public String getLabel() {
        return label;
    }

    /** 태그 > 관리자 화면 표시값 (네임스페이스 뗀 값, 유형은 대문자) */
    public String toDisplayValue(String tag) {
        String value = extractValue(tag);
        return isDisplayedInUppercase ? value.toUpperCase(Locale.ROOT) : value;
    }

    /** 태그 > 네임스페이스 (구분자 없거나 목록에 없으면 null) */
    public static QuestionInternalTagNamespace fromTagOrNull(String tag) {
        String namespacePrefix = extractPrefixOrNull(tag);
        if (namespacePrefix == null) {
            return null;
        }
        for (QuestionInternalTagNamespace namespace : values()) {
            if (namespace.prefix.equals(namespacePrefix)) {
                return namespace;
            }
        }
        return null;
    }

    /** 태그 > 첫 구분자 앞 (구분자 없으면 null) */
    public static String extractPrefixOrNull(String tag) {
        int separatorIndex = tag == null ? -1 : tag.indexOf(SEPARATOR);
        return separatorIndex < 0 ? null : tag.substring(0, separatorIndex);
    }

    /** 태그 > 첫 구분자 뒤 값 (구분자 없으면 태그 그대로) */
    public static String extractValue(String tag) {
        int separatorIndex = tag.indexOf(SEPARATOR);
        return separatorIndex < 0 ? tag : tag.substring(separatorIndex + 1);
    }
}
