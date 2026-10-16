package com.passql.member.push;

/** 기기 1대 발송 대상: 토큰, 앱 아이콘 숫자(APNs badge, 회원의 안 읽은 알림 수) */
public record PushTarget(String token, int badgeCount) {
}
