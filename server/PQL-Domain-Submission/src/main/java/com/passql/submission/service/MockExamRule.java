package com.passql.submission.service;

import com.passql.submission.constant.MockExamSubject;

import java.time.Duration;

/**
 * SQLD 모의고사 형식 단일 원본 (공식 기준: dataq.or.kr SQL 개발자 시험 안내, 2026-11-07 확인)
 * 앱·웹은 목록 응답의 examRule 로만 표시 (숫자 복사 금지)
 */
public final class MockExamRule {

    // 전체 문항 수 (1과목 10 + 2과목 40)
    public static final int TOTAL_QUESTION_COUNT = 50;
    // 문항당 배점 (점)
    public static final int POINTS_PER_QUESTION = 2;
    // 만점 (점)
    public static final int MAX_SCORE = TOTAL_QUESTION_COUNT * POINTS_PER_QUESTION;
    // 합격 총점 (점, 이상)
    public static final int PASS_SCORE = 60;
    // 과락 기준 (과목 만점 대비 %, 미만이면 과락)
    public static final int SUBJECT_FAIL_BELOW_PERCENT = 40;
    // 시험 시간 (분)
    public static final int DURATION_MINUTES = 90;
    public static final Duration DURATION = Duration.ofMinutes(DURATION_MINUTES);
    // 마감 뒤 답 저장·제출 묶음 허용 (네트워크 지연 흡수, 초)
    public static final Duration SUBMIT_GRACE = Duration.ofSeconds(15);
    // 시험지 보기 수 (4지선다)
    public static final int CHOICE_COUNT_PER_QUESTION = 4;

    private MockExamRule() {
    }

    /** 과목 만점 (점) */
    public static int maxScoreOf(MockExamSubject subject) {
        return subject.getQuestionCount() * POINTS_PER_QUESTION;
    }

    /** 과락 기준 점수 (점, 미만이면 과락): 1과목 8, 2과목 32 */
    public static int failBelowScoreOf(MockExamSubject subject) {
        return maxScoreOf(subject) * SUBJECT_FAIL_BELOW_PERCENT / 100;
    }
}
