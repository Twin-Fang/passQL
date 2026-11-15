package com.passql.submission.constant;

import com.passql.common.util.RequestEnumParser;

/**
 * SQLD 과목 2개: 1과목 데이터 모델링의 이해(토픽 data_modeling), 2과목 SQL 기본 및 활용(그 외 토픽)
 * 과목별 문항 수는 공식 기준 (dataq.or.kr SQL 개발자 시험 안내)
 */
public enum MockExamSubject {

    SUBJECT_ONE("데이터 모델링의 이해", 10),
    SUBJECT_TWO("SQL 기본 및 활용", 40);

    // 1과목 토픽 코드 (topic.code)
    public static final String SUBJECT_ONE_TOPIC_CODE = "data_modeling";

    private final String displayName;
    private final int questionCount;

    MockExamSubject(String displayName, int questionCount) {
        this.displayName = displayName;
        this.questionCount = questionCount;
    }

    public String getDisplayName() {
        return displayName;
    }

    public int getQuestionCount() {
        return questionCount;
    }

    /** 토픽 코드 > 과목 (data_modeling 만 1과목) */
    public static MockExamSubject fromTopicCode(String topicCode) {
        return SUBJECT_ONE_TOPIC_CODE.equals(topicCode) ? SUBJECT_ONE : SUBJECT_TWO;
    }

    /** 과목 필터 요청값 > 과목 (null·공백 > null 전체, 없는 값 > INVALID_INPUT_VALUE, #1081) */
    public static MockExamSubject fromFilterRequestValue(String requestValue) {
        if (requestValue == null || requestValue.isBlank()) {
            return null;
        }
        return RequestEnumParser.parse(MockExamSubject.class, requestValue);
    }
}
