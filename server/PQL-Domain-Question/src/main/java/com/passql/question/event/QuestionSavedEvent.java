package com.passql.question.event;

import java.util.UUID;

/**
 * 관리자 문제 등록 저장됨 > 커밋 후 벡터 색인 적재
 * 롤백된 문제는 발행돼도 리스너가 실행되지 않음 (AFTER_COMMIT)
 */
public record QuestionSavedEvent(UUID questionUuid) {}
