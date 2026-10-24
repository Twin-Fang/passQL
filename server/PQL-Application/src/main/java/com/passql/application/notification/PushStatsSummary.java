package com.passql.application.notification;

import com.passql.member.entity.PushSendHistory;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 최근 N일 발송 통계: 발송 건수, 알림함 받은·읽은 회원 수와 읽음률(%), 푸시 대상 기기·성공 수와 성공률(%)
 * 집계 대상은 실제 발송만 (테스트·회수·예약·취소 제외)
 */
public record PushStatsSummary(int days, int sendCount, long recipientCount, long readCount, long readRatePercent,
                               long targetDeviceCount, long successCount, long deliverySuccessRatePercent) {

    public static PushStatsSummary of(int days, List<PushSendHistory> histories, Map<UUID, Long> readCountByHistory) {
        long recipientCount = histories.stream().mapToLong(PushSendHistory::getRecipientCount).sum();
        long readCount = histories.stream().mapToLong(h -> readCountByHistory.getOrDefault(h.getPushSendHistoryUuid(), 0L)).sum();
        long targetDeviceCount = histories.stream().mapToLong(PushSendHistory::getTargetDeviceCount).sum();
        long successCount = histories.stream().mapToLong(PushSendHistory::getSuccessCount).sum();
        return new PushStatsSummary(days, histories.size(), recipientCount, readCount,
                toPercent(readCount, recipientCount), targetDeviceCount, successCount, toPercent(successCount, targetDeviceCount));
    }

    /** 비율(%): 분모 0 이면 0 */
    private static long toPercent(long part, long total) {
        return total == 0 ? 0 : part * 100 / total;
    }
}
