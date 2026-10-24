package com.passql.meta.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.CertType;
import com.passql.meta.dto.ExamScheduleBulkResult;
import com.passql.meta.dto.ExamScheduleCreateRequest;
import com.passql.meta.dto.ExamScheduleResponse;
import com.passql.meta.dto.ExamScheduleUpdateRequest;
import com.passql.meta.entity.ExamSchedule;
import com.passql.meta.repository.ExamScheduleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ExamScheduleService {

    // 시험 날짜는 한국 기준이므로 서버 시간대와 무관하게 KST 로 오늘을 계산한다.
    private static final ZoneId KST = ZoneId.of("Asia/Seoul");
    // 일괄 등록 오류 안내에 싣는 줄 수 (건)
    private static final int MAX_REPORTED_PARSE_ERRORS = 5;

    private final ExamScheduleRepository examScheduleRepository;
    private final ApplicationEventPublisher eventPublisher;

    public List<ExamScheduleResponse> getSchedulesByCertType(CertType certType) {
        return examScheduleRepository.findByCertTypeOrderByRoundAsc(certType).stream()
                .map(ExamScheduleResponse::from)
                .toList();
    }

    public ExamScheduleResponse getSelectedSchedule() {
        return findEffectiveSchedule()
                .map(ExamScheduleResponse::from)
                .orElse(null);
    }

    /**
     * 화면에 보여 줄 시험 일정.
     *
     * 관리자가 고른 일정이 아직 지나지 않았으면 그것을 쓰고, 이미 지났으면 다가오는 가장 가까운 시험으로 넘어간다.
     * 시험이 끝난 뒤 관리자가 다음 회차로 바꾸지 않으면 홈에 "D+129" 처럼 지난 시험이 계속 보이던 문제를 막는다.
     * 다가오는 시험이 없으면 선택된 일정을 그대로 돌려준다(아무것도 없는 것보다 낫다).
     */
    public Optional<ExamSchedule> findEffectiveSchedule() {
        LocalDate today = LocalDate.now(KST);
        Optional<ExamSchedule> selected = examScheduleRepository.findFirstByIsSelectedTrue();
        if (selected.isPresent() && !selected.get().getExamDate().isBefore(today)) {
            return selected;
        }
        Optional<ExamSchedule> upcoming =
                examScheduleRepository.findFirstByExamDateGreaterThanEqualOrderByExamDateAsc(today);
        return upcoming.isPresent() ? upcoming : selected;
    }

    public List<ExamScheduleResponse> getAllSchedules(CertType certType) {
        if (certType == null) {
            return examScheduleRepository.findAllByOrderByCertTypeAscRoundAsc().stream()
                    .map(ExamScheduleResponse::from)
                    .toList();
        }
        return getSchedulesByCertType(certType);
    }

    @Transactional
    public ExamScheduleResponse createSchedule(ExamScheduleCreateRequest request) {
        CertType certType = CertType.fromRequestValue(request.getCertType());

        if (examScheduleRepository.existsByCertTypeAndRound(certType, request.getRound())) {
            throw new CustomException(ErrorCode.EXAM_SCHEDULE_DUPLICATE);
        }

        ExamSchedule schedule = ExamSchedule.builder()
                .certType(certType)
                .round(request.getRound())
                .examDate(request.getExamDate())
                .isSelected(false)
                .build();

        ExamSchedule saved = examScheduleRepository.save(schedule);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EXAM_SCHEDULE, saved.getExamScheduleUuid(),
                AdminAuditAction.CREATE, null, toScheduleAuditSummary(saved)));
        return ExamScheduleResponse.from(saved);
    }

    /** 시험 일정 수정 (#479): 회차 바뀌면 중복 검사 > 회차·시험일 교체 */
    @Transactional
    public void updateSchedule(UUID examScheduleUuid, ExamScheduleUpdateRequest request) {
        ExamSchedule schedule = examScheduleRepository.findById(examScheduleUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.EXAM_SCHEDULE_NOT_FOUND));
        boolean isRoundChanged = !schedule.getRound().equals(request.round());
        if (isRoundChanged && examScheduleRepository.existsByCertTypeAndRound(schedule.getCertType(), request.round())) {
            throw new CustomException(ErrorCode.EXAM_SCHEDULE_DUPLICATE);
        }
        Map<String, Object> before = toScheduleAuditSummary(schedule);
        schedule.setRound(request.round());
        schedule.setExamDate(request.examDate());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EXAM_SCHEDULE, examScheduleUuid,
                AdminAuditAction.UPDATE, before, toScheduleAuditSummary(schedule)));
    }

    @Transactional
    public void selectSchedule(UUID examScheduleUuid) {
        ExamSchedule target = examScheduleRepository.findById(examScheduleUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.EXAM_SCHEDULE_NOT_FOUND));

        examScheduleRepository.findFirstByIsSelectedTrue()
                .ifPresent(current -> current.setIsSelected(false));

        target.setIsSelected(true);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EXAM_SCHEDULE, examScheduleUuid,
                AdminAuditAction.ACTIVATE, null, toScheduleAuditSummary(target)));
    }

    @Transactional
    public void deleteSchedule(UUID examScheduleUuid) {
        ExamSchedule schedule = examScheduleRepository.findById(examScheduleUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.EXAM_SCHEDULE_NOT_FOUND));

        examScheduleRepository.delete(schedule);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EXAM_SCHEDULE, examScheduleUuid,
                AdminAuditAction.DELETE, toScheduleAuditSummary(schedule), null));
    }

    /** 한국 기준 오늘 (지난 일정 표시·정리 기준) */
    public LocalDate getTodayInKorea() {
        return LocalDate.now(KST);
    }

    /** 지난 일정 건수 (정리 버튼 표시용, 자격증 구분 없이 전체) */
    public long countPastSchedules() {
        return examScheduleRepository.countByExamDateBefore(getTodayInKorea());
    }

    /**
     * 시험 일정 일괄 등록: 텍스트 해석(잘못된 줄 있으면 전체 거부) > 이미 있는 회차는 건너뜀 > 나머지 등록
     * 형식은 ExamScheduleBulkTextParser (한 줄에 "자격증 회차 시험일")
     */
    @Transactional
    public ExamScheduleBulkResult importSchedules(String text) {
        ExamScheduleBulkTextParser.ParseResult parseResult = ExamScheduleBulkTextParser.parse(text);
        if (!parseResult.errors().isEmpty()) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, String.join(" / ", parseResult.errors().stream().limit(MAX_REPORTED_PARSE_ERRORS).toList()));
        }
        if (parseResult.entries().isEmpty()) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "등록할 일정이 없습니다.");
        }
        Set<String> seenRoundKeys = new HashSet<>();
        List<String> createdRoundLabels = new ArrayList<>();
        int skippedDuplicateCount = 0;
        for (ExamScheduleBulkTextParser.Entry entry : parseResult.entries()) {
            String roundKey = entry.certType() + "-" + entry.round();
            boolean isDuplicate = !seenRoundKeys.add(roundKey)
                    || examScheduleRepository.existsByCertTypeAndRound(entry.certType(), entry.round());
            if (isDuplicate) {
                skippedDuplicateCount++;
                continue;
            }
            examScheduleRepository.save(ExamSchedule.builder().certType(entry.certType()).round(entry.round())
                    .examDate(entry.examDate()).isSelected(false).build());
            createdRoundLabels.add(roundKey + " " + entry.examDate());
        }
        if (!createdRoundLabels.isEmpty()) {
            eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EXAM_SCHEDULE, "bulk", AdminAuditAction.IMPORT,
                    null, AdminAuditEvent.summary("createdCount", createdRoundLabels.size(), "created", createdRoundLabels)));
        }
        log.info("[exam schedule import] done : created={}, skippedDuplicates={}", createdRoundLabels.size(), skippedDuplicateCount);
        return new ExamScheduleBulkResult(createdRoundLabels.size(), skippedDuplicateCount);
    }

    /** 지난 일정 정리: 시험일이 오늘(KST)보다 이전인 일정 삭제 (선택된 일정이 지났어도 삭제, 홈은 다가오는 시험으로 자동 전환) */
    @Transactional
    public ExamScheduleBulkResult deletePastSchedules() {
        List<ExamSchedule> pastSchedules = examScheduleRepository.findByExamDateBefore(getTodayInKorea());
        if (pastSchedules.isEmpty()) {
            return new ExamScheduleBulkResult(0, 0);
        }
        List<String> deletedLabels = pastSchedules.stream()
                .map(schedule -> schedule.getCertType() + "-" + schedule.getRound() + " " + schedule.getExamDate())
                .toList();
        examScheduleRepository.deleteAll(pastSchedules);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.EXAM_SCHEDULE, "past", AdminAuditAction.DELETE,
                AdminAuditEvent.summary("deletedCount", deletedLabels.size(), "deleted", deletedLabels), null));
        log.info("[exam schedule cleanup] deleted past schedules : count={}", deletedLabels.size());
        return new ExamScheduleBulkResult(deletedLabels.size(), 0);
    }

    /** 감사 기록용 일정 요약 */
    private Map<String, Object> toScheduleAuditSummary(ExamSchedule schedule) {
        return AdminAuditEvent.summary("certType", schedule.getCertType(), "round", schedule.getRound(),
                "examDate", schedule.getExamDate());
    }
}
