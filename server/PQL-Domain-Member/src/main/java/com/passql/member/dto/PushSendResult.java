package com.passql.member.dto;

/** 푸시 발송 결과 수: 대상 기기, 성공, 실패, 만료로 삭제한 토큰 */
public record PushSendResult(int targetDeviceCount, int successCount, int failureCount, int removedTokenCount) {
}
