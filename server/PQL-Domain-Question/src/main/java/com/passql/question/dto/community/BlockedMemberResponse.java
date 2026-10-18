package com.passql.question.dto.community;

import java.time.LocalDateTime;
import java.util.UUID;

/** 내 차단 목록 1건: 해제는 blockUuid 로 (차단당한 회원 UUID 비노출) */
public record BlockedMemberResponse(UUID blockUuid, String nickname, LocalDateTime blockedAt) {
}
