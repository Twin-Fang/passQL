package com.passql.application.notification;

import com.passql.member.entity.PushSendHistory;

/** 관리자 발송 이력 한 줄: 발송 정보 + 알림함 읽은 수·읽음률(%) */
public record PushHistoryRow(PushSendHistory history, long readCount, long readRatePercent) {

    public static PushHistoryRow of(PushSendHistory history, long readCount) {
        long recipientCount = history.getRecipientCount();
        long readRatePercent = recipientCount == 0 ? 0 : readCount * 100 / recipientCount;
        return new PushHistoryRow(history, readCount, readRatePercent);
    }
}
