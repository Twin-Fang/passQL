package com.passql.member.dto;

/** 기기 푸시 토큰 등록 결과: 이 기기의 알림 수신 동의 여부 */
public record PushTokenResponse(Boolean isPushEnabled) {
}
