package com.passql.question.service;

import com.passql.question.dto.ExecuteResult;

import java.util.ArrayList;
import java.util.List;

/**
 * 선택지 세트 재시도 피드백 누적: 동치 SQL, 직전 실행 결과(결과 표 문제는 거부 사유 포함), 기준 결과
 * 생성 1회 실행 동안만 유지, 다음 시도 AI 요청에 포함
 */
final class ChoiceSetRetryFeedback {

    // MULTIPLE_CORRECT 실패 시 정답과 동일한 결과를 낸 오답 SQL 누적
    private final List<String> equivalentSqls = new ArrayList<>();
    // 실패 시 직전 시도 선택지별 실제 실행 결과 (매 시도 교체)
    private List<String> previousChoiceResultLines = List.of();
    // 기준 SQL 실행 결과 포함 여부: 프롬프트가 받을 때만 첫 시도에 1회 실행 (#720)
    private final boolean shouldIncludeAnswerResult;
    private ExecuteResult expectedResult;

    ChoiceSetRetryFeedback(boolean shouldIncludeAnswerResult) {
        this.shouldIncludeAnswerResult = shouldIncludeAnswerResult;
    }

    List<String> equivalentSqls() {
        return equivalentSqls;
    }

    List<String> previousChoiceResultLines() {
        return previousChoiceResultLines;
    }

    void replacePreviousChoiceResultLines(List<String> choiceResultLines) {
        this.previousChoiceResultLines = choiceResultLines;
    }

    /** 기준 SQL 결과가 필요한데 아직 실행 전인지 */
    boolean isExpectedResultPending() {
        return shouldIncludeAnswerResult && expectedResult == null;
    }

    ExecuteResult expectedResult() {
        return expectedResult;
    }

    void recordExpectedResult(ExecuteResult executedExpectedResult) {
        this.expectedResult = executedExpectedResult;
    }
}
