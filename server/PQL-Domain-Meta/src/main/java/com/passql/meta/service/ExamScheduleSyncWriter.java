package com.passql.meta.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.meta.constant.CertType;
import com.passql.meta.constant.ExamScheduleSource;
import com.passql.meta.constant.ExamScheduleSyncFailureReason;
import com.passql.meta.constant.ExamScheduleSyncTrigger;
import com.passql.meta.dto.DataqScheduleParseResult;
import com.passql.meta.dto.ParsedExamRound;
import com.passql.meta.entity.ExamSchedule;
import com.passql.meta.entity.ExamScheduleSyncRun;
import com.passql.meta.repository.ExamScheduleRepository;
import com.passql.meta.repository.ExamScheduleSyncRunRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 시험 일정 수집 결과 저장 (#991): 잠금 > 회차 감소 검사 > 회차 기준 upsert > 수집 기록
 * 덮어쓰기 규칙: 수동 고정 행은 건너뜀, 그 외(수동 입력 포함)는 공식 값과 다른 칸만 바꾸고 감사 로그(system)에 전후 값 기록,
 * 공식 칸이 "-"(빈 칸)이면 기존 값 유지, 표에 없는 회차는 건드리지 않음
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ExamScheduleSyncWriter {

    // 수집 잠금 키 (pg advisory lock, 다른 잠금과 겹치지 않는 임의 상수)
    static final long SYNC_LOCK_KEY = 991_000_001L;

    private final ExamScheduleRepository examScheduleRepository;
    private final ExamScheduleSyncRunRepository examScheduleSyncRunRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** 해석 성공분 반영 (다른 서버가 잠금 중이면 empty, 회차 감소면 실패 기록) */
    @Transactional
    public Optional<ExamScheduleSyncRun> applyParsedSchedule(ExamScheduleSyncTrigger triggerType, LocalDateTime startedAt,
                                                             DataqScheduleParseResult parseResult, LocalDateTime now) {
        if (!examScheduleSyncRunRepository.tryAcquireTransactionLock(SYNC_LOCK_KEY)) {
            return Optional.empty();
        }
        Integer parsedMaxRound = parseResult.findMaxRound();
        Optional<Integer> lastSuccessMaxRound = examScheduleSyncRunRepository.findFirstByIsSuccessTrueOrderByStartedAtDesc()
                .map(ExamScheduleSyncRun::getMaxRound);
        if (lastSuccessMaxRound.isPresent() && parsedMaxRound < lastSuccessMaxRound.get()) {
            return Optional.of(examScheduleSyncRunRepository.save(ExamScheduleSyncRun.failure(triggerType, startedAt, now,
                    ExamScheduleSyncFailureReason.ROUND_DECREASED,
                    "max round " + parsedMaxRound + " < last success " + lastSuccessMaxRound.get(), toRoundsText(parseResult))));
        }

        Map<Integer, ExamSchedule> scheduleByRound = examScheduleRepository.findByCertTypeOrderByRoundAsc(CertType.SQLD).stream()
                .collect(Collectors.toMap(ExamSchedule::getRound, Function.identity()));
        Set<Integer> examYearsBeforeSync = scheduleByRound.values().stream()
                .map(schedule -> schedule.getExamDate().getYear()).collect(Collectors.toSet());
        int createdCount = 0;
        int updatedCount = 0;
        int skippedLockedCount = 0;
        for (ParsedExamRound parsedRound : parseResult.rounds()) {
            ExamSchedule schedule = scheduleByRound.get(parsedRound.round());
            if (schedule == null) {
                createSchedule(parsedRound, now);
                createdCount++;
            } else if (Boolean.TRUE.equals(schedule.getIsManualLocked())) {
                skippedLockedCount++;
            } else if (applyChanges(schedule, parsedRound, now)) {
                updatedCount++;
            }
        }
        // 새 연도 공개: 이번에 회차를 만들었고 그 연도 SQLD 일정이 전에 하나도 없었음
        Integer publishedYear = createdCount > 0 && !examYearsBeforeSync.contains(parseResult.scheduleYear())
                ? parseResult.scheduleYear() : null;
        ExamScheduleSyncRun run = examScheduleSyncRunRepository.save(ExamScheduleSyncRun.success(triggerType, startedAt, now,
                parseResult.scheduleYear(), parseResult.yearSource().name(), parseResult.rounds().size(), parsedMaxRound,
                createdCount, updatedCount, skippedLockedCount, publishedYear));
        log.info("[exam schedule sync] applied : year={}, created={}, updated={}, skippedLocked={}, publishedYear={}",
                parseResult.scheduleYear(), createdCount, updatedCount, skippedLockedCount, publishedYear);
        return Optional.of(run);
    }

    /** 실패 기록 (일정은 바꾸지 않음) */
    @Transactional
    public ExamScheduleSyncRun recordFailure(ExamScheduleSyncTrigger triggerType, LocalDateTime startedAt,
                                             LocalDateTime now, ExamScheduleSyncFailureReason failureReason,
                                             String failureDetail, String sourceExcerpt) {
        log.warn("[exam schedule sync] failed : reason={}, detail={}", failureReason, failureDetail);
        return examScheduleSyncRunRepository.save(ExamScheduleSyncRun.failure(triggerType, startedAt, now,
                failureReason, failureDetail, sourceExcerpt));
    }

    private void createSchedule(ParsedExamRound parsedRound, LocalDateTime now) {
        ExamSchedule saved = examScheduleRepository.save(ExamSchedule.builder()
                .certType(CertType.SQLD)
                .round(parsedRound.round())
                .examDate(parsedRound.examDate())
                .isSelected(false)
                .applicationStartDate(parsedRound.applicationStartDate())
                .applicationEndDate(parsedRound.applicationEndDate())
                .admissionTicketDate(parsedRound.admissionTicketDate())
                .preliminaryScoreStartDate(parsedRound.preliminaryScoreStartDate())
                .preliminaryScoreEndDate(parsedRound.preliminaryScoreEndDate())
                .resultAnnouncementDate(parsedRound.resultAnnouncementDate())
                .source(ExamScheduleSource.AUTO)
                .isManualLocked(false)
                .lastCollectedAt(now)
                .build());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EXAM_SCHEDULE, saved.getExamScheduleUuid(),
                AdminAuditAction.CREATE, null, AdminAuditEvent.summary("round", parsedRound.round(),
                        "examDate", parsedRound.examDate(), "source", ExamScheduleSource.AUTO)));
    }

    /** 공식 값과 다른 칸만 반영 + 전후 값 감사 기록, 바뀐 칸이 있으면 true (수집 시각은 항상 갱신) */
    private boolean applyChanges(ExamSchedule schedule, ParsedExamRound parsedRound, LocalDateTime now) {
        Map<String, Object> before = new LinkedHashMap<>();
        Map<String, Object> after = new LinkedHashMap<>();
        applyIfChanged("examDate", schedule.getExamDate(), parsedRound.examDate(), schedule::setExamDate, before, after);
        applyIfChanged("applicationStartDate", schedule.getApplicationStartDate(), parsedRound.applicationStartDate(),
                schedule::setApplicationStartDate, before, after);
        applyIfChanged("applicationEndDate", schedule.getApplicationEndDate(), parsedRound.applicationEndDate(),
                schedule::setApplicationEndDate, before, after);
        applyIfChanged("admissionTicketDate", schedule.getAdmissionTicketDate(), parsedRound.admissionTicketDate(),
                schedule::setAdmissionTicketDate, before, after);
        applyIfChanged("preliminaryScoreStartDate", schedule.getPreliminaryScoreStartDate(),
                parsedRound.preliminaryScoreStartDate(), schedule::setPreliminaryScoreStartDate, before, after);
        applyIfChanged("preliminaryScoreEndDate", schedule.getPreliminaryScoreEndDate(),
                parsedRound.preliminaryScoreEndDate(), schedule::setPreliminaryScoreEndDate, before, after);
        applyIfChanged("resultAnnouncementDate", schedule.getResultAnnouncementDate(), parsedRound.resultAnnouncementDate(),
                schedule::setResultAnnouncementDate, before, after);
        if (schedule.getSource() != ExamScheduleSource.AUTO) {
            before.put("source", schedule.getSource());
            after.put("source", ExamScheduleSource.AUTO);
            schedule.setSource(ExamScheduleSource.AUTO);
        }
        schedule.setLastCollectedAt(now);
        if (after.isEmpty()) {
            return false;
        }
        before.put("round", schedule.getRound());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EXAM_SCHEDULE, schedule.getExamScheduleUuid(),
                AdminAuditAction.UPDATE, before, after));
        log.info("[exam schedule sync] round updated : round={}, before={} -> after={}", schedule.getRound(), before, after);
        return true;
    }

    // 공식 칸이 비었으면 유지, 값이 다르면 교체
    private static void applyIfChanged(String fieldName, LocalDate currentValue, LocalDate parsedValue,
                                       Consumer<LocalDate> setter, Map<String, Object> before, Map<String, Object> after) {
        if (parsedValue == null || parsedValue.equals(currentValue)) {
            return;
        }
        before.put(fieldName, currentValue);
        after.put(fieldName, parsedValue);
        setter.accept(parsedValue);
    }

    // 회차 감소 실패 원문: 해석한 회차·시험일 목록
    private static String toRoundsText(DataqScheduleParseResult parseResult) {
        return parseResult.rounds().stream()
                .map(round -> "제" + round.round() + "회 " + round.examDate())
                .collect(Collectors.joining(", "));
    }
}
