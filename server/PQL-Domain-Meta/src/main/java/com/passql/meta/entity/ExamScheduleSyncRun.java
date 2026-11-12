package com.passql.meta.entity;

import com.passql.common.entity.BaseEntity;
import com.passql.common.util.TextPreview;
import com.passql.meta.constant.ExamScheduleSyncFailureReason;
import com.passql.meta.constant.ExamScheduleSyncTrigger;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 시험 일정 수집 1회 기록 (#991): 실행 방식, 시각, 성공 여부, 실패 사유·원문 일부, 반영 건수, 새 연도 공개
 * 실패 행은 일정을 바꾸지 않은 시도 (관리자 화면 수집 상태·대시보드 경고의 원본)
 */
@Entity
@Table(name = "exam_schedule_sync_run",
    indexes = @Index(name = "idx_exam_schedule_sync_run_started_at", columnList = "started_at"))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ExamScheduleSyncRun extends BaseEntity {

    // 실패 상세 최대 길이 (자)
    public static final int MAX_FAILURE_DETAIL_LENGTH = 500;
    // 원문 일부 최대 길이 (자)
    public static final int MAX_SOURCE_EXCERPT_LENGTH = 1000;

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID examScheduleSyncRunUuid;

    @Enumerated(EnumType.STRING)
    @Column(length = 20, nullable = false)
    private ExamScheduleSyncTrigger triggerType;

    @Column(nullable = false)
    private LocalDateTime startedAt;

    private LocalDateTime finishedAt;

    @Column(nullable = false)
    private Boolean isSuccess = false;

    @Enumerated(EnumType.STRING)
    @Column(length = 40)
    private ExamScheduleSyncFailureReason failureReason;

    @Column(length = MAX_FAILURE_DETAIL_LENGTH)
    private String failureDetail;

    @Column(columnDefinition = "TEXT")
    private String sourceExcerpt;

    // 해석한 일정 연도·연도 결정 근거 (HEADING·CAPTION·KNOWN_ROUND·REFERENCE_DATE)
    private Integer scheduleYear;

    @Column(length = 20)
    private String yearSource;

    // 해석한 SQLD 회차 수·마지막 회차
    @Column(nullable = false)
    private Integer collectedRoundCount = 0;

    private Integer maxRound;

    // 반영 건수: 새로 만든 회차, 값이 바뀐 회차, 수동 고정이라 건너뛴 회차
    @Column(nullable = false)
    private Integer createdCount = 0;

    @Column(nullable = false)
    private Integer updatedCount = 0;

    @Column(nullable = false)
    private Integer skippedLockedCount = 0;

    // 이번 수집으로 처음 생긴 연도 (새 연도 공개 알림 대상, 없으면 null)
    private Integer publishedYear;

    // 새 연도 공개 알림을 보냈는지 (publishedYear 있을 때만 의미)
    @Column(nullable = false)
    private Boolean isPublishAnnounced = false;

    /** 성공 기록 */
    public static ExamScheduleSyncRun success(ExamScheduleSyncTrigger triggerType, LocalDateTime startedAt,
                                              LocalDateTime finishedAt, int scheduleYear, String yearSource,
                                              int collectedRoundCount, int maxRound, int createdCount, int updatedCount,
                                              int skippedLockedCount, Integer publishedYear) {
        ExamScheduleSyncRun run = start(triggerType, startedAt, finishedAt);
        run.isSuccess = true;
        run.scheduleYear = scheduleYear;
        run.yearSource = yearSource;
        run.collectedRoundCount = collectedRoundCount;
        run.maxRound = maxRound;
        run.createdCount = createdCount;
        run.updatedCount = updatedCount;
        run.skippedLockedCount = skippedLockedCount;
        run.publishedYear = publishedYear;
        return run;
    }

    /** 실패 기록 (상세·원문은 길이 제한까지만) */
    public static ExamScheduleSyncRun failure(ExamScheduleSyncTrigger triggerType, LocalDateTime startedAt,
                                              LocalDateTime finishedAt, ExamScheduleSyncFailureReason failureReason,
                                              String failureDetail, String sourceExcerpt) {
        ExamScheduleSyncRun run = start(triggerType, startedAt, finishedAt);
        run.failureReason = failureReason;
        run.failureDetail = TextPreview.truncate(failureDetail, MAX_FAILURE_DETAIL_LENGTH);
        run.sourceExcerpt = TextPreview.truncate(sourceExcerpt, MAX_SOURCE_EXCERPT_LENGTH);
        return run;
    }

    /** 새 연도 공개 알림 발송 처리 */
    public void markPublishAnnounced() {
        this.isPublishAnnounced = true;
    }

    private static ExamScheduleSyncRun start(ExamScheduleSyncTrigger triggerType, LocalDateTime startedAt,
                                             LocalDateTime finishedAt) {
        ExamScheduleSyncRun run = new ExamScheduleSyncRun();
        run.triggerType = triggerType;
        run.startedAt = startedAt;
        run.finishedAt = finishedAt;
        return run;
    }
}
