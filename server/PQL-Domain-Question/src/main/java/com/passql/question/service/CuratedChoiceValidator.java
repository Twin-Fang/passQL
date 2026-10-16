package com.passql.question.service;

import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.constant.ExecutionMode;
import com.passql.question.dto.CuratedChoiceDto;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 고정 보기 검증 (#511): 통과 > null, 거부 > 사유 문자열 (가져오기 항목 FAIL 사유로 노출)
 * 규칙 6개: 보기 4개, 정답 1개, 키 비어 있지 않고 중복 없음, 본문 필수, 검증 근거 필수, 실행형은 SQL 보기만
 * CURATED_ONLY 는 보기 필수, 그 외 정책은 보기 금지 (고정되지 않는 세트가 생기는 것 방지)
 */
public final class CuratedChoiceValidator {

    // 고정 세트 보기 개수 (SQLD 4지선다)
    public static final int CURATED_CHOICE_COUNT = 4;

    private CuratedChoiceValidator() {
    }

    /** 정책·보기 목록 > 거부 사유 (통과 시 null) */
    public static String findRejectReason(ChoiceSetPolicy policy, ExecutionMode executionMode, List<CuratedChoiceDto> choices) {
        boolean isCuratedPolicy = policy == ChoiceSetPolicy.CURATED_ONLY;
        if (choices == null || choices.isEmpty()) {
            return isCuratedPolicy ? "CURATED_ONLY 문제는 보기(choices) 필수" : null;
        }
        if (!isCuratedPolicy) {
            return "보기(choices)는 CURATED_ONLY 정책에서만 허용";
        }
        if (choices.size() != CURATED_CHOICE_COUNT) {
            return "보기는 정확히 " + CURATED_CHOICE_COUNT + "개 필요 (현재 " + choices.size() + "개)";
        }
        long correctCount = choices.stream().filter(choice -> Boolean.TRUE.equals(choice.isCorrect())).count();
        if (correctCount != 1) {
            return "정답 보기는 정확히 1개 필요 (현재 " + correctCount + "개)";
        }
        String invalidChoiceReason = findInvalidChoiceReason(choices);
        if (invalidChoiceReason != null) {
            return invalidChoiceReason;
        }
        // 실행형은 제출 시 보기 본문을 SQL 로 실행 > TEXT 보기 금지
        boolean hasTextChoice = choices.stream().anyMatch(choice -> !"SQL".equalsIgnoreCase(choice.kind()));
        if (executionMode == ExecutionMode.EXECUTABLE && hasTextChoice) {
            return "EXECUTABLE 문제는 SQL 보기(kind=SQL)만 허용";
        }
        return null;
    }

    // 보기별 키·본문·근거 확인
    private static String findInvalidChoiceReason(List<CuratedChoiceDto> choices) {
        Set<String> choiceKeys = new HashSet<>();
        for (CuratedChoiceDto choice : choices) {
            if (isBlank(choice.choiceKey())) {
                return "보기 키(choiceKey) 비어 있음";
            }
            if (!choiceKeys.add(choice.choiceKey())) {
                return "보기 키 중복: " + choice.choiceKey();
            }
            if (isBlank(choice.body())) {
                return "보기 본문 비어 있음: " + choice.choiceKey();
            }
            if (isBlank(choice.rationale())) {
                return "보기 검증 근거(rationale) 비어 있음: " + choice.choiceKey();
            }
        }
        return null;
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
