package com.passql.common.util;

/**
 * 긴 문자열 미리보기: 길이 제한 자르기 (null > 빈 문자열)
 * 용도별 길이는 아래 상수로만 지정
 */
public final class TextPreview {

    // 문제 목록 요약 카드의 지문 미리보기 (문자 수)
    public static final int QUESTION_SUMMARY_STEM_LENGTH = 100;
    // 관리자 일일 챌린지 화면의 지문 미리보기 (문자 수)
    public static final int DAILY_CHALLENGE_STEM_LENGTH = 80;
    // 오답 목록·가져오기 결과의 지문 미리보기 (문자 수, 말줄임 포함 전 길이)
    public static final int SHORT_STEM_LENGTH = 50;
    // 검증 로그에 남기는 선택지 본문 미리보기 (문자 수)
    public static final int LOG_CHOICE_BODY_LENGTH = 50;
    // 검증 오류 메시지에 넣는 선택지 본문 미리보기 (문자 수)
    public static final int ERROR_MESSAGE_CHOICE_BODY_LENGTH = 30;
    // 실행 로그에 남기는 SQL 미리보기 (문자 수)
    public static final int LOG_SQL_LENGTH = 120;

    private static final String ELLIPSIS = "...";

    private TextPreview() {
    }

    /** 앞에서 maxLength 자까지 (넘치면 그냥 자름) */
    public static String truncate(String text, int maxLength) {
        if (text == null) {
            return "";
        }
        return text.length() > maxLength ? text.substring(0, maxLength) : text;
    }

    /** 앞에서 maxLength 자까지 + 넘치면 "..." 덧붙임 */
    public static String truncateWithEllipsis(String text, int maxLength) {
        if (text == null) {
            return "";
        }
        return text.length() > maxLength ? text.substring(0, maxLength) + ELLIPSIS : text;
    }
}
