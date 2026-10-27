package com.passql.application.concept.dto;

import java.util.Map;

/**
 * 확인 문제 채점 결과: 정답 여부, 정답 키, 풀이, 다시 읽기 앵커, 보기별 근거, 개념 누적(문제별 마지막 답 기준)
 */
public record ConceptCheckAnswerResponse(
    boolean isCorrect,
    String correctKey,
    String explanation,
    String rereadAnchor,
    Map<String, String> rationaleByChoiceKey,
    int checkCorrectCount,
    int checkSolvedCount
) {
}
