package com.passql.meta.dto;

/** 시험 일정 일괄 처리 결과 (count: 등록·삭제된 건수, skippedDuplicateCount: 이미 있어 건너뛴 건수) */
public record ExamScheduleBulkResult(int count, int skippedDuplicateCount) {}
