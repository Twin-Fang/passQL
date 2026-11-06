package com.passql.submission.constant;

/**
 * 모의고사 회차 상태 3개: DRAFT 구성 중(관리자만), PUBLISHED 공개(문항 고정), ARCHIVED 보관(사용자 목록 제외, 기록 유지)
 */
public enum MockExamRoundStatus {
    DRAFT,
    PUBLISHED,
    ARCHIVED
}
