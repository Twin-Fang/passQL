package com.passql.meta.service;

import com.passql.common.util.ServiceTimeZone;
import com.passql.meta.client.DataqSchedulePageClient;
import com.passql.meta.constant.CertType;
import com.passql.meta.constant.ExamScheduleSyncFailureReason;
import com.passql.meta.constant.ExamScheduleSyncTrigger;
import com.passql.meta.dto.DataqScheduleParseResult;
import com.passql.meta.dto.ExamScheduleSyncResult;
import com.passql.meta.entity.ExamSchedule;
import com.passql.meta.entity.ExamScheduleSyncRun;
import com.passql.meta.repository.ExamScheduleRepository;
import com.passql.meta.repository.ExamScheduleSyncRunRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * SQLD 시험 일정 자동 수집 (#991): 공식 페이지 가져오기 > 규칙 기반 해석 > 검증 > 저장(ExamScheduleSyncWriter)
 * 실패하면 일정은 덮어쓰지 않고 사유·원문 일부를 exam_schedule_sync_run 에 기록 (관리자 화면·대시보드 경고)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ExamScheduleSyncService {

    private final DataqSchedulePageClient dataqSchedulePageClient;
    private final ExamScheduleRepository examScheduleRepository;
    private final ExamScheduleSyncRunRepository examScheduleSyncRunRepository;
    private final ExamScheduleSyncWriter examScheduleSyncWriter;

    /** 수집 1회 (HTTP 는 트랜잭션 밖, 어떤 실패도 예외로 번지지 않고 기록으로 남김) */
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public ExamScheduleSyncResult syncNow(ExamScheduleSyncTrigger triggerType) {
        LocalDateTime startedAt = LocalDateTime.now(ServiceTimeZone.ZONE);
        try {
            DataqSchedulePageClient.FetchResult fetchResult = dataqSchedulePageClient.fetchSchedulePage();
            if (!fetchResult.isSuccess()) {
                return ExamScheduleSyncResult.from(examScheduleSyncWriter.recordFailure(triggerType, startedAt, now(),
                        ExamScheduleSyncFailureReason.FETCH_FAILED, fetchResult.failureDetail(), null));
            }
            DataqScheduleParseResult parseResult = DataqScheduleHtmlParser.parse(fetchResult.html(),
                    startedAt.toLocalDate(), findKnownSqldExamDateByRound());
            if (!parseResult.isSuccess()) {
                return ExamScheduleSyncResult.from(examScheduleSyncWriter.recordFailure(triggerType, startedAt, now(),
                        parseResult.failureReason(), parseResult.failureDetail(), parseResult.sourceExcerpt()));
            }
            Optional<ExamScheduleSyncRun> run = examScheduleSyncWriter.applyParsedSchedule(triggerType, startedAt, parseResult, now());
            if (run.isEmpty()) {
                log.info("[exam schedule sync] skipped : reason=locked by other server, trigger={}", triggerType);
                return ExamScheduleSyncResult.skippedByOtherServer();
            }
            return ExamScheduleSyncResult.from(run.get());
        } catch (RuntimeException e) {
            log.error("[exam schedule sync] unexpected error : trigger={}, cause={}", triggerType, e.getClass().getSimpleName(), e);
            return ExamScheduleSyncResult.from(examScheduleSyncWriter.recordFailure(triggerType, startedAt, now(),
                    ExamScheduleSyncFailureReason.UNEXPECTED_ERROR, e.getClass().getSimpleName(), null));
        }
    }

    /** 마지막 시도 (성공·실패 공통) */
    public Optional<ExamScheduleSyncRun> findLatestRun() {
        return examScheduleSyncRunRepository.findFirstByOrderByStartedAtDesc();
    }

    /** 마지막 성공 */
    public Optional<ExamScheduleSyncRun> findLatestSuccessRun() {
        return examScheduleSyncRunRepository.findFirstByIsSuccessTrueOrderByStartedAtDesc();
    }

    /** 최근 시도 10건 */
    public List<ExamScheduleSyncRun> findRecentRuns() {
        return examScheduleSyncRunRepository.findTop10ByOrderByStartedAtDesc();
    }

    /** 아직 알리지 않은 새 연도 공개 중 가장 최근 (기준 시각 이후 수집분만, 새 연도 공개 알림용) */
    public Optional<ExamScheduleSyncRun> findUnannouncedPublishedRun(LocalDateTime startedAfter) {
        return examScheduleSyncRunRepository
                .findFirstByIsSuccessTrueAndPublishedYearIsNotNullAndIsPublishAnnouncedFalseAndStartedAtAfterOrderByStartedAtDesc(startedAfter);
    }

    /** 새 연도 공개 알림 발송 처리 (같은 공개를 다시 알리지 않게) */
    @Transactional
    public void markPublishAnnounced(UUID examScheduleSyncRunUuid) {
        examScheduleSyncRunRepository.findById(examScheduleSyncRunUuid).ifPresent(ExamScheduleSyncRun::markPublishAnnounced);
    }

    // 저장된 SQLD 회차 > 시험일 (연도 보정 단서)
    private Map<Integer, LocalDate> findKnownSqldExamDateByRound() {
        return examScheduleRepository.findByCertTypeOrderByRoundAsc(CertType.SQLD).stream()
                .collect(Collectors.toMap(ExamSchedule::getRound, ExamSchedule::getExamDate));
    }

    private static LocalDateTime now() {
        return LocalDateTime.now(ServiceTimeZone.ZONE);
    }
}
