package com.passql.question.dto.explanation;

import java.util.List;

/**
 * 선택지 세트 1개의 구조화 해설 저장 형태 (#521): AI 응답 JSON 그대로 question_choice_set.explanation_json 에 저장
 * 고른 보기와 무관한 세트 단위 내용만 담는다 (고른 보기별 판정 문구는 조회 시 ChoiceExplanationComposer 가 조립)
 * 응답의 풀이 메모(workingNotes)는 필드가 없어 파싱 때 버려짐 > 저장·노출 안 함 (#716)
 */
public record ChoiceSetExplanation(
    String correctChoiceKey,
    String correctReason,
    List<KeyConcept> keyConcepts,
    List<String> confusingPoints,
    List<ChoiceAnalysis> choiceAnalyses,
    String examTip
) {}
