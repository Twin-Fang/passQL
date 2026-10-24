package com.passql.application.service;

import com.passql.application.notification.MemberNotificationService;
import com.passql.application.notification.NotificationSettingService;
import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.MemberActivityLogger;
import com.passql.member.constant.MemberNotificationType;
import com.passql.member.constant.PushLinkTarget;
import com.passql.question.constant.CorrectionScope;
import com.passql.question.constant.ReportCategory;
import com.passql.question.constant.ReportStatus;
import com.passql.question.constant.ReportSummarySort;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionReport;
import com.passql.question.repository.QuestionReportRepository;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.repository.SubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class QuestionReportService {

    /** Controller가 DTO로 변환하는 데 사용하는 집계 행 — Web 모듈 DTO 의존 없이 Application 레이어에서 반환 */
    public record ReportSummaryRow(
            UUID questionUuid,
            String stem,
            long totalCount,
            long pendingCount,
            Map<String, Long> categoryDistribution,
            LocalDateTime latestReportedAt
    ) {}

    /** 관리자 신고 목록 한 페이지 + 필터 범위 전체 합계 (요약 배지용) */
    public record ReportSummaryPage(
            List<ReportSummaryRow> content,
            int page,
            int size,
            long totalElements,
            int totalPages,
            long totalReportCount,
            long pendingReportCount
    ) {}

    /** 관리자 신고 목록 조건: 상태(없으면 전체), 신고일 기간(양끝 포함, 없으면 제한 없음), 정렬 */
    public record ReportSummaryFilter(
            String status,
            LocalDate fromDate,
            LocalDate toDate,
            ReportSummarySort sort
    ) {}

    /** 일괄 처리 결과: 처리한 건 수, 이미 처리돼 건너뛴 건 수 */
    public record BulkProcessResult(int processedCount, int skippedCount) {}

    private final QuestionReportRepository questionReportRepository;
    private final QuestionRepository questionRepository;
    private final SubmissionRepository submissionRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final MemberNotificationService memberNotificationService;
    private final NotificationSettingService notificationSettingService;

    // 기간 필터 미지정 시 쓰는 시각 범위 (createdAt >= 시작, < 끝)
    private static final LocalDateTime UNBOUNDED_FROM_AT = LocalDateTime.of(2000, 1, 1, 0, 0);
    private static final LocalDateTime UNBOUNDED_TO_AT = LocalDateTime.of(2999, 1, 1, 0, 0);
    // 처리 사유 메모 최대 길이 (question_report.resolution_note VARCHAR(500))
    private static final int MAX_RESOLUTION_NOTE_LENGTH = 500;
    // 상태 필터 전체 값 (화면 드롭다운)
    private static final String ALL_STATUS_FILTER_VALUE = "ALL";

    // 신고 처리 결과 알림 문구 (알림함 title 100자·body 500자 이내)
    private static final String RESOLVED_NOTIFICATION_TITLE = "신고하신 문제를 처리했어요";
    private static final String RESOLVED_NOTIFICATION_BODY = "제보해 주신 내용을 확인하고 처리를 마쳤어요. 소중한 의견 감사합니다.";
    private static final String DISMISSED_NOTIFICATION_TITLE = "신고하신 내용을 검토했어요";
    private static final String DISMISSED_NOTIFICATION_BODY = "검토 결과 문제를 그대로 유지하기로 했어요. 의견 주셔서 감사합니다.";

    /** 사용자 신고 제출 */
    @Transactional
    public void submitReport(UUID questionUuid, UUID memberUuid, UUID submissionUuid,
                             UUID choiceSetUuid, List<ReportCategory> categories, String detail) {
        // 입력 검증 — Controller 대신 Service에서 처리 (CLAUDE.md 규칙: Controller 비즈니스 로직 금지)
        if (submissionUuid == null) {
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }
        if (categories == null || categories.isEmpty()) {
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }
        if (categories.contains(ReportCategory.ETC) && (detail == null || detail.isBlank())) {
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }
        if (questionReportRepository.existsByMemberUuidAndSubmissionUuid(memberUuid, submissionUuid)) {
            throw new CustomException(ErrorCode.REPORT_ALREADY_EXISTS);
        }
        QuestionReport report = QuestionReport.builder()
                .questionUuid(questionUuid)
                .choiceSetUuid(choiceSetUuid)
                .memberUuid(memberUuid)
                .submissionUuid(submissionUuid)
                .categories(categories)
                .detail(detail)
                .build();
        questionReportRepository.save(report);
        MemberActivityLogger.recordQuestionReported(memberUuid, questionUuid, categories);
    }

    /** 신고 여부 조회 — questionUuid + memberUuid + submissionUuid 3중 조건으로 정합성 보장 */
    public boolean isReported(UUID questionUuid, UUID memberUuid, UUID submissionUuid) {
        return questionReportRepository
                .existsByQuestionUuidAndMemberUuidAndSubmissionUuid(questionUuid, memberUuid, submissionUuid);
    }

    /** 관리자: 문제별 집계 목록 — 문제 줄기·카테고리 분포는 일괄 조회로 N+1 방지, 상태·기간 필터와 정렬 적용 */
    public List<ReportSummaryRow> getReportSummaries(ReportSummaryFilter filter) {
        // 상태 필터 (없음 또는 ALL > 전체, 잘못된 값 > 400)
        boolean isAllStatus = filter.status() == null || filter.status().isBlank()
                || ALL_STATUS_FILTER_VALUE.equals(filter.status());
        List<ReportStatus> statuses = isAllStatus
                ? List.of(ReportStatus.values())
                : List.of(ReportStatus.fromRequestValue(filter.status()));
        LocalDateTime fromAt = filter.fromDate() == null ? UNBOUNDED_FROM_AT : filter.fromDate().atStartOfDay();
        LocalDateTime toAt = filter.toDate() == null ? UNBOUNDED_TO_AT : filter.toDate().plusDays(1).atStartOfDay();

        List<Object[]> summaryRows = questionReportRepository.findReportSummaryGroupByQuestion(statuses, fromAt, toAt);
        Map<UUID, Map<String, Long>> categoryDistributionByQuestionUuid =
                findCategoryDistributionByQuestionUuid(statuses, fromAt, toAt);

        // 집계 결과의 questionUuid 목록을 한 번에 조회 (N+1 방지)
        List<UUID> questionUuids = summaryRows.stream().map(row -> (UUID) row[0]).collect(Collectors.toList());
        Map<UUID, String> stemMap = questionRepository.findAllById(questionUuids).stream()
                .collect(Collectors.toMap(Question::getQuestionUuid, Question::getStem));

        return summaryRows.stream()
                .map(row -> {
                    UUID questionUuid = (UUID) row[0];
                    return new ReportSummaryRow(
                            questionUuid,
                            stemMap.getOrDefault(questionUuid, "(삭제된 문제)"),
                            ((Number) row[1]).longValue(),
                            ((Number) row[2]).longValue(),
                            categoryDistributionByQuestionUuid.getOrDefault(questionUuid, Map.of()),
                            (LocalDateTime) row[3]);
                })
                .sorted(toSummaryComparator(filter.sort()))
                .collect(Collectors.toList());
    }

    /** 문제별 카테고리 분포 (카테고리 이름 > 신고 수) */
    private Map<UUID, Map<String, Long>> findCategoryDistributionByQuestionUuid(
            List<ReportStatus> statuses, LocalDateTime fromAt, LocalDateTime toAt) {
        Map<UUID, Map<String, Long>> distributionByQuestionUuid = new HashMap<>();
        for (Object[] row : questionReportRepository.findCategoryCountGroupByQuestion(statuses, fromAt, toAt)) {
            distributionByQuestionUuid
                    .computeIfAbsent((UUID) row[0], ignored -> new LinkedHashMap<>())
                    .put(((ReportCategory) row[1]).name(), ((Number) row[2]).longValue());
        }
        return distributionByQuestionUuid;
    }

    /** 정렬 기준 > 비교자 (같으면 최근 신고순) */
    private Comparator<ReportSummaryRow> toSummaryComparator(ReportSummarySort sort) {
        Comparator<ReportSummaryRow> latestFirst = Comparator.comparing(
                ReportSummaryRow::latestReportedAt, Comparator.nullsLast(Comparator.reverseOrder()));
        ReportSummarySort effectiveSort = sort == null ? ReportSummarySort.REPORT_COUNT_DESC : sort;
        return switch (effectiveSort) {
            case REPORT_COUNT_DESC -> Comparator.comparingLong(ReportSummaryRow::totalCount).reversed().thenComparing(latestFirst);
            case PENDING_COUNT_DESC -> Comparator.comparingLong(ReportSummaryRow::pendingCount).reversed().thenComparing(latestFirst);
            case LATEST_DESC -> latestFirst;
        };
    }

    /**
     * 관리자: 문제별 집계 한 페이지 (집계 행은 신고된 문제 수만큼이라 메모리에서 자름, #479)
     */
    public ReportSummaryPage getReportSummaryPage(ReportSummaryFilter filter, int page, int size) {
        List<ReportSummaryRow> rows = getReportSummaries(filter);
        int fromIndex = Math.min(page * size, rows.size());
        int toIndex = Math.min(fromIndex + size, rows.size());
        int totalPages = (int) Math.ceil(rows.size() / (double) size);
        long totalReportCount = rows.stream().mapToLong(ReportSummaryRow::totalCount).sum();
        long pendingReportCount = rows.stream().mapToLong(ReportSummaryRow::pendingCount).sum();
        return new ReportSummaryPage(rows.subList(fromIndex, toIndex), page, size, rows.size(), totalPages,
                totalReportCount, pendingReportCount);
    }

    /** 미처리 신고 수 — 대시보드 카드 */
    public long countPendingReports() {
        return questionReportRepository.countByStatus(ReportStatus.PENDING);
    }

    /** 관리자: 신고 기각 (보정·비활성화 없이 종료), 처리자 = 로그인한 관리자 아이디 */
    @Transactional
    public void dismissReport(UUID reportUuid, String resolvedByAdminUsername) {
        dismissReport(reportUuid, resolvedByAdminUsername, null);
    }

    /** 관리자: 신고 1건 기각 + 사유 메모 */
    @Transactional
    public void dismissReport(UUID reportUuid, String resolvedByAdminUsername, String resolutionNote) {
        QuestionReport report = findPendingReport(reportUuid);
        dismissOne(report, resolvedByAdminUsername, normalizeResolutionNote(resolutionNote));
    }

    /** 관리자: 신고 여러 건 기각 — 한 트랜잭션, 이미 처리된 건은 건너뜀, 없는 UUID 있으면 전체 취소 */
    @Transactional
    public BulkProcessResult dismissReports(List<UUID> reportUuids, String resolvedByAdminUsername, String resolutionNote) {
        String normalizedNote = normalizeResolutionNote(resolutionNote);
        List<QuestionReport> pendingReports = findReportsForBulk(reportUuids).stream()
                .filter(QuestionReport::isPending).toList();
        pendingReports.forEach(report -> dismissOne(report, resolvedByAdminUsername, normalizedNote));
        return new BulkProcessResult(pendingReports.size(), distinctCount(reportUuids) - pendingReports.size());
    }

    private void dismissOne(QuestionReport report, String resolvedByAdminUsername, String resolutionNote) {
        report.dismiss(resolvedByAdminUsername, resolutionNote);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.REPORT, report.getQuestionReportUuid(),
                AdminAuditAction.DISMISS,
                AdminAuditEvent.summary("status", ReportStatus.PENDING),
                AdminAuditEvent.summary("status", ReportStatus.DISMISSED, "questionUuid", report.getQuestionUuid(),
                        "resolutionNote", resolutionNote)));
        notifyReporterOfResult(report, false, false);
    }

    /** 관리자: 특정 문제 신고 건 목록 */
    public List<QuestionReport> getReportsByQuestion(UUID questionUuid) {
        return questionReportRepository.findByQuestionUuidOrderByCreatedAtDesc(questionUuid);
    }

    /** 관리자: 문제 단건 조회 — Controller에서 NotFound 처리에 사용 */
    public Optional<Question> getQuestion(UUID questionUuid) {
        return questionRepository.findById(questionUuid);
    }

    /** 관리자: 신고 처리 (resolve), 처리자 = 로그인한 관리자 아이디 */
    @Transactional
    public void resolveReport(UUID reportUuid, String resolvedByAdminUsername,
                              CorrectionScope correctionScope, Boolean deactivateQuestion) {
        resolveReport(reportUuid, resolvedByAdminUsername, correctionScope, deactivateQuestion, null);
    }

    /** 관리자: 신고 1건 처리 + 사유 메모 */
    @Transactional
    public void resolveReport(UUID reportUuid, String resolvedByAdminUsername,
                              CorrectionScope correctionScope, Boolean deactivateQuestion, String resolutionNote) {
        validateCorrectionScope(correctionScope);
        QuestionReport report = findPendingReport(reportUuid);
        resolvePendingReports(List.of(report), resolvedByAdminUsername, correctionScope,
                Boolean.TRUE.equals(deactivateQuestion), normalizeResolutionNote(resolutionNote));
    }

    /**
     * 관리자: 신고 여러 건 처리 — 한 트랜잭션 (검증 > 상태 변경 > 비활성화 > 보정 > 알림)
     * 이미 처리된 건은 건너뜀, 없는 UUID 있거나 보정 범위가 맞지 않으면 전체 취소
     */
    @Transactional
    public BulkProcessResult resolveReports(List<UUID> reportUuids, String resolvedByAdminUsername,
                                            CorrectionScope correctionScope, Boolean deactivateQuestion,
                                            String resolutionNote) {
        validateCorrectionScope(correctionScope);
        String normalizedNote = normalizeResolutionNote(resolutionNote);
        List<QuestionReport> pendingReports = findReportsForBulk(reportUuids).stream()
                .filter(QuestionReport::isPending).toList();
        resolvePendingReports(pendingReports, resolvedByAdminUsername, correctionScope,
                Boolean.TRUE.equals(deactivateQuestion), normalizedNote);
        return new BulkProcessResult(pendingReports.size(), distinctCount(reportUuids) - pendingReports.size());
    }

    /** 미처리 신고 묶음 처리 (문제 비활성화·소급 보정은 문제·선택지 세트마다 1회) */
    private void resolvePendingReports(List<QuestionReport> pendingReports, String resolvedByAdminUsername,
                                       CorrectionScope correctionScope, boolean isDeactivateQuestion,
                                       String resolutionNote) {
        // 검증 (CHOICE_SET_ONLY 는 모든 신고에 선택지 세트 필요)
        if (correctionScope == CorrectionScope.CHOICE_SET_ONLY
                && pendingReports.stream().anyMatch(report -> report.getChoiceSetUuid() == null)) {
            throw new CustomException(ErrorCode.REPORT_CHOICE_SET_REQUIRED);
        }

        // 1. 신고 상태 변경
        for (QuestionReport report : pendingReports) {
            report.resolve(resolvedByAdminUsername, correctionScope, resolutionNote);
            eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.REPORT, report.getQuestionReportUuid(),
                    AdminAuditAction.RESOLVE,
                    AdminAuditEvent.summary("status", ReportStatus.PENDING),
                    AdminAuditEvent.summary("status", report.getStatus(), "correctionScope", correctionScope,
                            "deactivateQuestion", isDeactivateQuestion, "questionUuid", report.getQuestionUuid(),
                            "resolutionNote", resolutionNote)));
        }

        // 2. 문제 비활성화 (문제별 1회)
        if (isDeactivateQuestion) {
            Set<UUID> questionUuids = pendingReports.stream().map(QuestionReport::getQuestionUuid)
                    .collect(Collectors.toCollection(LinkedHashSet::new));
            for (UUID questionUuid : questionUuids) {
                questionRepository.findById(questionUuid)
                        .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND))
                        .deactivate();
            }
        }

        // 3. Submission 소급 보정 (문제 또는 선택지 세트별 1회)
        if (correctionScope == CorrectionScope.QUESTION_WIDE) {
            pendingReports.stream().map(QuestionReport::getQuestionUuid).distinct()
                    .forEach(submissionRepository::correctAllByQuestionUuid);
        } else if (correctionScope == CorrectionScope.CHOICE_SET_ONLY) {
            pendingReports.stream().map(QuestionReport::getChoiceSetUuid).distinct()
                    .forEach(submissionRepository::correctAllByChoiceSetUuid);
        }

        // 4. 신고한 회원에게 처리 결과 알림
        pendingReports.forEach(report -> notifyReporterOfResult(report, true, isDeactivateQuestion));
    }

    /** correctionScope null 입력 방어 — null이면 DB에 null이 저장되어 데이터 정합성 오염 */
    private void validateCorrectionScope(CorrectionScope correctionScope) {
        if (correctionScope == null) {
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }
    }

    /** 미처리 신고 1건 조회 (없음 > 404, 이미 처리 > REPORT_ALREADY_RESOLVED) */
    private QuestionReport findPendingReport(UUID reportUuid) {
        QuestionReport report = questionReportRepository.findById(reportUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.REPORT_NOT_FOUND));
        if (!report.isPending()) {
            throw new CustomException(ErrorCode.REPORT_ALREADY_RESOLVED);
        }
        return report;
    }

    /** 일괄 처리 대상 조회 (빈 목록 > 400, 없는 UUID > 404) */
    private List<QuestionReport> findReportsForBulk(List<UUID> reportUuids) {
        if (reportUuids == null || reportUuids.isEmpty()) {
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }
        List<QuestionReport> reports = questionReportRepository.findByQuestionReportUuidIn(new HashSet<>(reportUuids));
        if (reports.size() != distinctCount(reportUuids)) {
            throw new CustomException(ErrorCode.REPORT_NOT_FOUND);
        }
        return reports;
    }

    private int distinctCount(List<UUID> reportUuids) {
        return (int) reportUuids.stream().distinct().count();
    }

    /** 사유 메모 정리 (공백 > null, 500자 초과 > INVALID_REQUEST) */
    private String normalizeResolutionNote(String resolutionNote) {
        if (resolutionNote == null || resolutionNote.isBlank()) {
            return null;
        }
        String trimmedNote = resolutionNote.trim();
        if (trimmedNote.length() > MAX_RESOLUTION_NOTE_LENGTH) {
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }
        return trimmedNote;
    }

    /**
     * 신고 처리 결과 알림 (설정 notification.report_resolved.enabled 꺼짐이면 생략)
     * 처리 완료 > 문제 상세 이동 (비활성화한 문제는 홈), 기각 > 문제 상세 이동
     */
    private void notifyReporterOfResult(QuestionReport report, boolean isResolved, boolean isQuestionDeactivated) {
        if (!notificationSettingService.isReportResolvedEnabled()) {
            return;
        }
        PushLinkTarget linkTarget = isQuestionDeactivated ? PushLinkTarget.HOME : PushLinkTarget.QUESTION_DETAIL;
        memberNotificationService.notifyMember(report.getMemberUuid(), MemberNotificationType.REPORT_RESOLVED,
                isResolved ? RESOLVED_NOTIFICATION_TITLE : DISMISSED_NOTIFICATION_TITLE,
                isResolved ? RESOLVED_NOTIFICATION_BODY : DISMISSED_NOTIFICATION_BODY,
                linkTarget, isQuestionDeactivated ? null : report.getQuestionUuid());
    }
}
