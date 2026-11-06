package com.passql.meta.constant;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.util.Arrays;

/**
 * prompt_template.key_name 단일 원본: 코드가 활성 프롬프트를 읽는 키 전부 (#875)
 * keyName 은 운영 DB 행과 맞물린 와이어 값 > 바꾸지 않음, 관리자 등록 폼 선택지도 이 목록
 */
@Getter
@RequiredArgsConstructor
public enum PromptKey {

    // SQL 실행 오류 AI 해설
    EXPLAIN_ERROR("explain_error", "SQL 실행 오류 AI 해설"),
    // 선택지 세트 구조화 해설의 모델·온도 설정 (문구는 리소스 파일, 모델 비교 #356)
    DIFF_EXPLAIN("diff_explain", "선택지 해설 모델·온도 설정"),
    // 결과 화면 AI 코멘트 (세션 결과 + 누적 통계)
    AI_COMMENT("ai_comment", "결과 화면 AI 코멘트"),
    // 통계 화면 AI 분석 토픽별 한 문장 (본문은 운영 DB 에만, #861)
    AI_ANALYSIS_STATS("ai_analysis_stats", "통계 화면 AI 분석"),
    // 실행형 선택지 세트 생성 (ODD_ONE_OUT 외 SQL 보기 정책 기본)
    GENERATE_CHOICE_SET("generate_choice_set", "실행형 선택지 세트 생성"),
    // 개념형 선택지 세트 생성 (샌드박스 없이 텍스트 보기)
    GENERATE_CHOICE_SET_CONCEPT("generate_choice_set_concept", "개념형 선택지 세트 생성"),
    // RESULT_MATCH 선택지 세트 생성 (v3 이상: 오해 SQL 4개 후보, 지시문은 운영 DB 에만, #828)
    GENERATE_CHOICE_SET_RESULT_MATCH("generate_choice_set_result_match", "결과 표 선택지 세트 생성"),
    // ODD_ONE_OUT 선택지 세트 생성 (같은 결과 3개 + 다른 결과 1개, SandboxValidator 3:1 판정과 짝, #699)
    GENERATE_CHOICE_SET_ODD_ONE_OUT("generate_choice_set_odd_one_out", "결과가 다른 것 고르기 선택지 세트 생성"),
    // 관리자 문제 전체 AI 생성 (미리보기)
    GENERATE_QUESTION_FULL("generate_question_full", "관리자 문제 AI 생성");

    // prompt_template.key_name 값
    private final String keyName;
    // 관리자 화면 표시용 용도
    private final String purpose;

    /** key_name 문자열이 코드가 읽는 키인지 */
    public static boolean isKnownKeyName(String keyName) {
        return Arrays.stream(values()).anyMatch(promptKey -> promptKey.keyName.equals(keyName));
    }
}
