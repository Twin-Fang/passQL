package com.passql.meta.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * 관리자 개념 문서 정렬 (값 없으면 RECENTLY_UPDATED)
 */
public enum ConceptDocSortType {
    RECENTLY_UPDATED("최근 수정순"),
    OLDEST_UPDATED("오래된 수정순"),
    TITLE_ASCENDING("제목순");

    // 화면 표시 이름
    private final String label;

    ConceptDocSortType(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    /** 요청값 > 정렬 (null·공백 > RECENTLY_UPDATED, 없는 값 > INVALID_INPUT_VALUE) */
    public static ConceptDocSortType fromRequestValueOrRecentlyUpdated(String requestValue) {
        if (requestValue == null || requestValue.isBlank()) {
            return RECENTLY_UPDATED;
        }
        return RequestEnumParser.parse(ConceptDocSortType.class, requestValue);
    }
}
