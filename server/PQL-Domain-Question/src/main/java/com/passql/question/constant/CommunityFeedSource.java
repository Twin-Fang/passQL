package com.passql.question.constant;

import com.passql.common.util.RequestEnumParser;

import java.util.Locale;

/** 피드 탭: 뜨는 토론(hot), 최신 경향(trend), 내가 푼 문제(solved), 내 의견(mine) */
public enum CommunityFeedSource {
    HOT,
    TREND,
    SOLVED,
    MINE;

    /** 요청값(hot, trend, solved, mine) > CommunityFeedSource (대소문자 무시, 비면 HOT) */
    public static CommunityFeedSource fromRequestValue(String requestValue) {
        if (requestValue == null || requestValue.isBlank()) {
            return HOT;
        }
        return RequestEnumParser.parse(CommunityFeedSource.class, requestValue.trim().toUpperCase(Locale.ROOT));
    }
}
