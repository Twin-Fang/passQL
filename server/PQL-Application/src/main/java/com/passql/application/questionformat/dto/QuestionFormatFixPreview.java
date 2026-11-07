package com.passql.application.questionformat.dto;

import java.util.List;
import java.util.UUID;

/**
 * 자동 정리 미리보기 문제 1개 (#905): 문제, 지문 앞부분, 모의고사 위치, 적용할 정리 이름, 바뀌는 필드
 */
public record QuestionFormatFixPreview(
        UUID questionUuid,
        String stemPreview,
        String mockExamLabel,
        List<String> fixNames,
        List<QuestionFormatFieldChange> changes
) {
}
