package com.passql.meta.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.FeedbackStatus;
import com.passql.meta.dto.FeedbackDeviceColumns;
import com.passql.meta.dto.FeedbackSearchCondition;
import com.passql.meta.entity.Feedback;
import com.passql.meta.repository.FeedbackRepository;
import com.passql.meta.repository.FeedbackSpecification;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collection;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** 글 검증: 앞뒤 공백 제거 > 비어 있음, 500자 초과 거절 > 정리된 글 */
    public String normalizeContent(String content) {
        if (content == null || content.isBlank()) {
            throw new CustomException(ErrorCode.FEEDBACK_CONTENT_EMPTY);
        }
        String trimmed = content.trim();
        if (trimmed.length() > 500) {
            throw new CustomException(ErrorCode.FEEDBACK_CONTENT_TOO_LONG);
        }
        return trimmed;
    }

    /** 의견 저장 (PENDING): 진단 컬럼, 로그 객체 키(logBytes 있을 때 feedbackUuid 로 계산) 포함, 즉시 flush (DB 오류를 업로드 전에 드러냄) */
    @Transactional
    public Feedback createFeedback(UUID memberUuid, String content, FeedbackDeviceColumns deviceColumns,
                                   String diagnosticsJson, Integer logBytes) {
        Feedback feedback = Feedback.builder()
            .memberUuid(memberUuid)
            .content(content)
            .status(FeedbackStatus.PENDING)
            .diagnostics(diagnosticsJson)
            .appVersion(deviceColumns.appVersion())
            .platform(deviceColumns.platform())
            .osVersion(deviceColumns.osVersion())
            .deviceModel(deviceColumns.deviceModel())
            .logBytes(logBytes)
            .build();
        Feedback saved = feedbackRepository.saveAndFlush(feedback);
        // 로그 객체 키는 저장 후 발급된 feedbackUuid 가 필요
        if (logBytes != null) {
            saved.setLogObjectKey(Feedback.logObjectKeyOf(saved.getFeedbackUuid()));
        }
        return saved;
    }

    /** 관리자 건의 검색: 조건(상태·키워드·회원 후보·기간) > 최신순 한 페이지 (memberUuids null 이면 회원 조건 없음) */
    public Page<Feedback> searchFeedbacksForAdmin(FeedbackSearchCondition condition, Collection<UUID> memberUuids,
                                                  Pageable pageable) {
        Specification<Feedback> specification = Specification.allOf(
            FeedbackSpecification.statusEquals(condition.getStatus()),
            FeedbackSpecification.contentContains(condition.getKeyword()),
            FeedbackSpecification.memberIn(memberUuids),
            FeedbackSpecification.createdFrom(condition.getFromDate()),
            FeedbackSpecification.createdTo(condition.getToDate()));
        return feedbackRepository.findAll(specification,
            PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(), Sort.by(Sort.Direction.DESC, "createdAt")));
    }

    public Feedback getFeedback(UUID feedbackUuid) {
        return feedbackRepository.findById(feedbackUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.FEEDBACK_NOT_FOUND));
    }

    /** 미처리(PENDING) 건의 수 — 대시보드 카드 */
    public long countPending() {
        return feedbackRepository.countByStatus(FeedbackStatus.PENDING);
    }

    /** 관리자 메모 저장 (공백만이면 삭제) */
    @Transactional
    public void updateAdminMemo(UUID feedbackUuid, String adminMemo) {
        Feedback feedback = feedbackRepository.findById(feedbackUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.FEEDBACK_NOT_FOUND));
        String previousMemo = feedback.getAdminMemo();
        feedback.setAdminMemo(adminMemo == null || adminMemo.isBlank() ? null : adminMemo.trim());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.FEEDBACK, feedbackUuid, AdminAuditAction.UPDATE,
            AdminAuditEvent.summary("adminMemo", previousMemo), AdminAuditEvent.summary("adminMemo", feedback.getAdminMemo())));
    }

    public Map<FeedbackStatus, Long> countByStatus() {
        Map<FeedbackStatus, Long> result = new EnumMap<>(FeedbackStatus.class);
        for (FeedbackStatus s : FeedbackStatus.values()) {
            result.put(s, 0L);
        }
        feedbackRepository.countGroupByStatus()
            .forEach(row -> result.put((FeedbackStatus) row[0], (Long) row[1]));
        return result;
    }

    /** 상태 변경 + 감사 기록 > 실제로 바뀐 경우만 변경된 건의 (같은 상태 재설정은 empty) */
    @Transactional
    public Optional<Feedback> updateStatus(UUID feedbackUuid, FeedbackStatus status) {
        Feedback feedback = feedbackRepository.findById(feedbackUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.FEEDBACK_NOT_FOUND));
        if (!applyStatus(feedback, status)) {
            return Optional.empty();
        }
        log.info("[FeedbackService] 건의사항 상태 변경: feedbackUuid={}, status={}", feedbackUuid, status);
        return Optional.of(feedback);
    }

    /** 일괄 상태 변경: 건별 감사 기록, 없는 건의는 건너뜀 > 실제로 바뀐 건 목록 (한 트랜잭션, 최대 100건) */
    @Transactional
    public List<Feedback> updateStatuses(Collection<UUID> feedbackUuids, FeedbackStatus status) {
        List<Feedback> changedFeedbacks = new ArrayList<>();
        for (Feedback feedback : feedbackRepository.findAllById(feedbackUuids)) {
            if (applyStatus(feedback, status)) {
                changedFeedbacks.add(feedback);
            }
        }
        log.info("[FeedbackService] 건의사항 일괄 상태 변경: count={}, status={}", changedFeedbacks.size(), status);
        return changedFeedbacks;
    }

    /** 상태 반영 + 감사 기록 > 바뀌었으면 true (같은 상태면 아무것도 안 함) */
    private boolean applyStatus(Feedback feedback, FeedbackStatus status) {
        FeedbackStatus previousStatus = feedback.getStatus();
        if (previousStatus == status) {
            return false;
        }
        feedback.setStatus(status);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.FEEDBACK, feedback.getFeedbackUuid(),
            AdminAuditAction.STATUS_CHANGE, AdminAuditEvent.summary("status", previousStatus),
            AdminAuditEvent.summary("status", status)));
        return true;
    }
}
