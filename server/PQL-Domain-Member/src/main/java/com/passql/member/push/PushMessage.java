package com.passql.member.push;

import java.util.Map;

/** 기기로 보낼 알림 1건: 제목, 본문, 앱 이동 데이터 ({@link PushDataKeys} 키, 문자열 값만) */
public record PushMessage(String title, String body, Map<String, String> data) {
}
