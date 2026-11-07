package com.passql.question.constant;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 문항 형식 위반 사유 (#905): 규칙 번호(이슈 본문 1~7) + 관리자 화면 표시 이름
 * 자동 정리 가능 여부는 위반 1건마다 따로 판정 (QuestionFormatViolation.isAutoFixable)
 */
@Getter
@RequiredArgsConstructor
public enum QuestionFormatViolationReason {

    FORBIDDEN_PUNCTUATION(1, "줄표, 가운뎃점 사용"),
    STEM_TABLE_DUPLICATES_SCHEMA(2, "스키마 표와 같은 지문 표"),
    STEM_DATA_TABLE_OUTSIDE_SCHEMA(2, "스키마 밖 데이터 표"),
    KEY_MARK_TEXT_IN_STEM(3, "지문에 PK·FK 글 표시"),
    COLUMN_TYPE_TEXT_IN_STEM(4, "지문에 스키마 자료형 반복"),
    SQL_KEYWORD_NOT_UPPERCASE(5, "SQL 키워드 소문자"),
    SQL_SELECT_LIST_TOO_LONG(5, "SELECT 목록 한 줄 초과"),
    SQL_KOREAN_COMMENT(5, "SQL 안 한글 주석"),
    QUESTION_SENTENCE_COUNT(6, "질문 문장 개수"),
    LIST_MARKER_NOT_DASH(7, "목록 기호");

    // 이슈 #905 규칙 번호 (1~7)
    private final int ruleNumber;
    private final String displayName;
}
