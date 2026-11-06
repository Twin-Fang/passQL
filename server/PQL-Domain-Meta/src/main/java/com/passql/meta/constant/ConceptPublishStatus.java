package com.passql.meta.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * 개념 공개 상태: 초안은 미리보기 회원만, 공개는 전체 회원
 */
public enum ConceptPublishStatus {

    DRAFT,      // 초안 (제작·검수 중)
    PUBLISHED;  // 공개

    /** 요청값 > ConceptPublishStatus (null·공백·없는 값 > INVALID_INPUT_VALUE) */
    public static ConceptPublishStatus fromRequestValue(String requestValue) {
        return RequestEnumParser.parse(ConceptPublishStatus.class, requestValue);
    }
}
