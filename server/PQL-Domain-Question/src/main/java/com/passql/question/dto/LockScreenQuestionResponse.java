package com.passql.question.dto;

import java.util.UUID;

/**
 * 잠금화면 출제 문제 1개 (#990, 앱이 GET /questions/{questionUuid} 로 상세를 열고 기존 제출 흐름을 그대로 씀)
 */
public record LockScreenQuestionResponse(
        UUID questionUuid
) {
}
