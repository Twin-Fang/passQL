package com.passql.question.event;

/**
 * 관리자 문제 비활성화됨(1건·일괄 공통, 요청당 1회) > 커밋 후 비활성 문제 벡터 정리 (#412)
 * 롤백되면 리스너가 실행되지 않음 (AFTER_COMMIT)
 */
public record QuestionsDeactivatedEvent() {}
