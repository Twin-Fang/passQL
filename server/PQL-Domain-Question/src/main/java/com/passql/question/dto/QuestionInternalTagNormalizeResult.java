package com.passql.question.dto;

import java.util.List;

/**
 * 내부 태그 목록 정규화 결과: 정규화·중복 제거한 태그 (입력 순서), 거부 사유 (통과면 null)
 */
public record QuestionInternalTagNormalizeResult(
        List<String> tags,
        String rejectReason
) {
    public static QuestionInternalTagNormalizeResult passed(List<String> tags) {
        return new QuestionInternalTagNormalizeResult(List.copyOf(tags), null);
    }

    public static QuestionInternalTagNormalizeResult rejected(String rejectReason) {
        return new QuestionInternalTagNormalizeResult(List.of(), rejectReason);
    }

    public boolean isValid() {
        return rejectReason == null;
    }
}
