package com.passql.member.push;

import java.util.List;

/** 기기 알림 발송 포트 (운영: FirebasePushMessageSender, 테스트: 가짜 구현) */
public interface PushMessageSender {

    /** 알림 1건 > 기기 여러 대 발송, 토큰별 결과 (기기마다 badge 가 달라도 됨, 발송 실패는 예외 대신 결과로) */
    List<PushDeliveryResult> send(PushMessage message, List<PushTarget> targets);
}
