package com.passql.question.service;

import com.passql.question.constant.ChoiceSetPolicy;
import com.passql.question.dto.CuratedChoiceDto;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 고정 보기 검증 (#511): 통과 > null, 거부 > 사유 문자열 (가져오기 항목 FAIL 사유로 노출)
 * 규칙 5개: 보기 4개, 정답 1개, 키 비어 있지 않고 중복 없음, 본문 필수, 검증 근거 필수
 * CURATED_ONLY 는 보기 필수, 그 외 정책은 보기를 보낸 경우에만 같은 규칙
 */
public final class CuratedChoiceValidator {

    // 고정 세트 보기 개수 (SQLD 4지선다)
    public static final int CURATED_CHOICE_COUNT = 4;

    private CuratedChoiceValidator() {
    }

    /** 정책·보기 목록 > 거부 사유 (통과 시 null) */
    public static String findRejectReason(ChoiceSetPolicy policy, List<CuratedChoiceDto> choices) {
        if (choices == null || choices.isEmpty()) {
            return policy == ChoiceSetPolicy.CURATED_ONLY ? "CURATED_ONLY 문제는 보기(choices) 필수" : null;
        }
        if (choices.size() != CURATED_CHOICE_COUNT) {
            return "보기는 정확히 " + CURATED_CHOICE_COUNT + "개 필요 (현재 " + choices.size() + "개)";
        }
        long correctCount = choices.stream().filter(choice -> Boolean.TRUE.equals(choice.isCorrect())).count();
        if (correctCount != 1) {
            return "정답 보기는 정확히 1개 필요 (현재 " + correctCount + "개)";
        }
        return findInvalidChoiceReason(choices);
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
