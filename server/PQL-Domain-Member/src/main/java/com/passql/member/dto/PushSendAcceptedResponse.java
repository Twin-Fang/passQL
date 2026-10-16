package com.passql.member.dto;

import java.util.UUID;

/** 발송 접수 결과: 이력 UUID, 알림함 대상 회원 수 (저장·푸시 전달은 커밋 후 비동기, 결과는 발송 이력에서 확인) */
public record PushSendAcceptedResponse(UUID pushSendHistoryUuid, long targetMemberCount) {
}
