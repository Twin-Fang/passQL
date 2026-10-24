package com.passql.question.dto;

import java.util.List;

/** 선택지 세트 일괄 처리 결과 (updated: 바뀐 건수, skipped: 건너뜀 건수, errors: 건너뜀 사유) */
public record AdminChoiceSetBulkResult(int updated, int skipped, List<String> errors) {}
