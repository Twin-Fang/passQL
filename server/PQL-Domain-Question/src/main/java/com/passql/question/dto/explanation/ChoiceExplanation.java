package com.passql.question.dto.explanation;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

/**
 * 고른 보기 기준 구조화 해설 (#521): 세트 해설 + 고른 보기 판정
 * 화면 배치 순서: verdict > correctReason > keyConcepts > confusingPoints > choiceAnalyses > examTip
 * 문장 안 `코드` 는 인라인 SQL 조각 (코드 블록 없음)
 */
public record ChoiceExplanation(
    @Schema(description = "고른 보기 키") String selectedChoiceKey,
    @Schema(description = "정답 보기 키") String correctChoiceKey,
    @Schema(description = "고른 보기가 정답인지") Boolean isSelectedCorrect,
    @Schema(description = "정답/오답 한 줄 판정 (서버가 정답 데이터로 조립)") String verdict,
    @Schema(description = "정답 근거 (2~3문장)") String correctReason,
    @Schema(description = "핵심 개념 1~3개") List<KeyConcept> keyConcepts,
    @Schema(description = "헷갈리는 지점 1~3개") List<String> confusingPoints,
    @Schema(description = "보기별 판정 (보기 키 순서)") List<ChoiceAnalysis> choiceAnalyses,
    @Schema(description = "시험 팁 한 줄") String examTip
) {}
