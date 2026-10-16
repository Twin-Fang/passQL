package com.passql.member.dto;

import java.util.UUID;

/** 푸시 수신 동의 기기 1대: 소유 회원, 토큰 */
public record PushDevice(UUID memberUuid, String token) {
}
