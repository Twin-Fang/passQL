package com.passql.question.dto;

import lombok.Getter;
import lombok.Setter;

/**
 * 관리자 문제 목록 필터: 토픽 코드, 난이도, 실행 모드, 지문 검색어(부분 일치), 활성 여부(ACTIVE·INACTIVE·ALL)
 * 품질: 신고 있는 문제만(isReportedOnly), 정렬(AdminQuestionSortType 이름, 없으면 최신순)
 */
@Getter
@Setter
public class AdminQuestionSearchCondition {

    private String topic;
    private Integer difficulty;
    private String executionMode;
    private String keyword;
    private String activeState;
    private Boolean isReportedOnly;
    private String sort;
}
