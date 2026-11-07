package com.passql.question.dto;

import com.passql.question.constant.QuestionFormatViolationReason;

import java.util.EnumSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 문항 형식 검사 결과 (#905): 위반 목록이 비면 통과, 아니면 사유별 거부
 */
public record QuestionFormatCheckResult(List<QuestionFormatViolation> violations) {

    public static QuestionFormatCheckResult of(List<QuestionFormatViolation> violations) {
        return new QuestionFormatCheckResult(List.copyOf(violations));
    }

    public boolean isPassed() {
        return violations.isEmpty();
    }

    /** 위반 사유 종류 (편집 저장 시 새로 생긴 사유 비교용) */
    public Set<QuestionFormatViolationReason> reasons() {
        if (violations.isEmpty()) return EnumSet.noneOf(QuestionFormatViolationReason.class);
        return violations.stream().map(QuestionFormatViolation::reason)
                .collect(Collectors.toCollection(() -> EnumSet.noneOf(QuestionFormatViolationReason.class)));
    }

    /** 주어진 사유만 남긴 결과 */
    public QuestionFormatCheckResult onlyReasons(Set<QuestionFormatViolationReason> keptReasons) {
        return of(violations.stream().filter(violation -> keptReasons.contains(violation.reason())).toList());
    }

    /** 위반 줄 목록 > 한 문자열 (오류 메시지·가져오기 사유) */
    public String toDisplayText(String delimiter) {
        return violations.stream().map(QuestionFormatViolation::toDisplayLine).collect(Collectors.joining(delimiter));
    }
}
