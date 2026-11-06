package com.passql.submission.service;

import java.util.Map;

/**
 * 자동 구성 기본 토픽별 문항 수 (#500 출제 경향 조사 7.2 표를 토픽 9개로 접은 값, 합계 1과목 10 · 2과목 40)
 * 관리자 구성 화면에서 회차마다 바꿀 수 있음
 */
public final class MockExamComposition {

    // 토픽 코드 > 문항 수 (목록에 없는 토픽은 0)
    public static final Map<String, Integer> DEFAULT_QUESTION_COUNT_BY_TOPIC_CODE = Map.of(
        "data_modeling", 10,
        "sql_basic_select", 5,
        "sql_function", 5,
        "sql_group_aggregate", 6,
        "sql_join", 5,
        "sql_subquery", 5,
        "sql_window", 5,
        "sql_hierarchy_pivot", 3,
        "sql_ddl_dml_tcl", 6);

    private MockExamComposition() {
    }
}
