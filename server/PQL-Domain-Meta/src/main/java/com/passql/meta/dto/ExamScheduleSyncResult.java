package com.passql.meta.dto;

import com.passql.meta.constant.ExamScheduleSyncFailureReason;
import com.passql.meta.entity.ExamScheduleSyncRun;

/**
 * 「지금 수집」 1회 결과 (관리자 화면 토스트용)
 *
 * @param isSkipped 다른 서버가 수집 중이라 이번 요청은 건너뜀 (기록 없음)
 */
public record ExamScheduleSyncResult(
        boolean isSuccess,
        boolean isSkipped,
        Integer scheduleYear,
        int createdCount,
        int updatedCount,
        int skippedLockedCount,
        ExamScheduleSyncFailureReason failureReason,
        String failureReasonLabel
) {
    public static ExamScheduleSyncResult from(ExamScheduleSyncRun run) {
        ExamScheduleSyncFailureReason failureReason = run.getFailureReason();
        return new ExamScheduleSyncResult(Boolean.TRUE.equals(run.getIsSuccess()), false, run.getScheduleYear(),
                run.getCreatedCount(), run.getUpdatedCount(), run.getSkippedLockedCount(), failureReason,
                failureReason == null ? null : failureReason.getLabel());
    }

    public static ExamScheduleSyncResult skippedByOtherServer() {
        return new ExamScheduleSyncResult(false, true, null, 0, 0, 0, null, null);
    }
}
