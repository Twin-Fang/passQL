package com.passql.member.repository;

import java.util.UUID;

/** 발송 1건의 알림함 집계: 받은 회원 수, 읽은 수 */
public interface NotificationReadStatProjection {

    UUID getPushSendHistoryUuid();

    long getRecipientCount();

    long getReadCount();
}
