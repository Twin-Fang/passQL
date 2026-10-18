package com.passql.question.constant;

import com.passql.common.util.RequestEnumParser;

import java.util.Locale;

/** 글 목록 정렬: 최신순, 좋아요순 */
public enum CommunityPostSort {
    LATEST,
    LIKES;

    /** 요청값(latest, likes) > CommunityPostSort (대소문자 무시, 비면 LATEST, 없는 값 > INVALID_INPUT_VALUE) */
    public static CommunityPostSort fromRequestValue(String requestValue) {
        if (requestValue == null || requestValue.isBlank()) {
            return LATEST;
        }
        return RequestEnumParser.parse(CommunityPostSort.class, requestValue.trim().toUpperCase(Locale.ROOT));
    }
}
