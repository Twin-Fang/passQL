package com.passql.application.community;

import java.util.UUID;

/**
 * 문제 의견의 노출 상태 변경 (작성·삭제·숨김·복원, #739) > 커밋 직후 해당 문제 집계 즉시 갱신
 */
public record CommunityDiscussionChangedEvent(UUID questionUuid) {
}
