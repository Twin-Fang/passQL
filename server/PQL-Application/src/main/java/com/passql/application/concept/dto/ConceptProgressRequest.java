package com.passql.application.concept.dto;

import com.passql.meta.constant.ConceptReadingDepth;
import com.passql.meta.constant.ConceptStudyMode;

/**
 * 개념 진행 저장 요청: null 칸은 기존값 유지, isRead 는 true 로만 바뀜
 */
public record ConceptProgressRequest(
    Boolean isRead,
    ConceptStudyMode lastMode,
    ConceptReadingDepth lastDepth
) {
}
