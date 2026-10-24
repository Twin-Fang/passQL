package com.passql.meta.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.MemberActivityLogger;
import com.passql.meta.constant.FeedbackStatus;
import com.passql.meta.dto.FeedbackListResponse;
import com.passql.meta.dto.FeedbackSubmitRequest;
import com.passql.meta.dto.FeedbackSubmitResponse;
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

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FeedbackService {

    private final FeedbackRepository feedbackRepository;
    private final ApplicationEventPublisher eventPublisher;

    @Transactional
    public FeedbackSubmitResponse submit(UUID memberUuid, FeedbackSubmitRequest request) {
        String content = request.getContent();

        if (content == null || content.isBlank()) {
            throw new CustomException(ErrorCode.FEEDBACK_CONTENT_EMPTY);
        }

        String trimmed = content.trim();

        if (trimmed.length() > 500) {
            throw new CustomException(ErrorCode.FEEDBACK_CONTENT_TOO_LONG);
        }

        Feedback feedback = Feedback.builder()
            .memberUuid(memberUuid)
            .content(trimmed)
            .status(FeedbackStatus.PENDING)
            .build();

        Feedback saved = feedbackRepository.save(feedback);
        MemberActivityLogger.recordFeedbackSubmitted(memberUuid, saved.getFeedbackUuid());
        return FeedbackSubmitResponse.from(saved);
    }

    public FeedbackListResponse getMyFeedbacks(UUID memberUuid) {
        List<Feedback> feedbacks = feedbackRepository.findByMemberUuidOrderByCreatedAtDesc(memberUuid);
        return FeedbackListResponse.of(feedbacks);
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

    @Transactional
    public void updateStatus(UUID feedbackUuid, FeedbackStatus status) {
        Feedback feedback = feedbackRepository.findById(feedbackUuid)
            .orElseThrow(() -> new CustomException(ErrorCode.FEEDBACK_NOT_FOUND));
        FeedbackStatus previousStatus = feedback.getStatus();
        feedback.setStatus(status);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.FEEDBACK, feedbackUuid, AdminAuditAction.STATUS_CHANGE,
            AdminAuditEvent.summary("status", previousStatus), AdminAuditEvent.summary("status", status)));
        log.info("[FeedbackService] 건의사항 상태 변경: feedbackUuid={}, status={}", feedbackUuid, status);
    }

    /** 일괄 상태 변경: 건별 감사 기록, 없는 건의는 건너뜀 > 변경한 건수 (한 트랜잭션, 최대 100건) */
    @Transactional
    public int updateStatuses(Collection<UUID> feedbackUuids, FeedbackStatus status) {
        int changedCount = 0;
        for (Feedback feedback : feedbackRepository.findAllById(feedbackUuids)) {
            FeedbackStatus previousStatus = feedback.getStatus();
            feedback.setStatus(status);
            eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.FEEDBACK, feedback.getFeedbackUuid(),
                AdminAuditAction.STATUS_CHANGE, AdminAuditEvent.summary("status", previousStatus),
                AdminAuditEvent.summary("status", status)));
            changedCount++;
        }
        log.info("[FeedbackService] 건의사항 일괄 상태 변경: count={}, status={}", changedCount, status);
        return changedCount;
    }

    /** 답변 기록: 답변 내용·시각 저장, 대기 건의는 검토완료로 (알림 전달은 호출부) */
    @Transactional
    public Feedback recordReply(UUID feedbackUuid, String replyMessage) {
        Feedback feedback = getFeedback(feedbackUuid);
        feedback.setReplyMessage(replyMessage.trim());
        feedback.setRepliedAt(LocalDateTime.now());
        if (feedback.getStatus() == FeedbackStatus.PENDING) {
            feedback.setStatus(FeedbackStatus.REVIEWED);
        }
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.FEEDBACK, feedbackUuid, AdminAuditAction.SEND,
            null, AdminAuditEvent.summary("replyMessage", feedback.getReplyMessage(), "status", feedback.getStatus())));
        return feedback;
    }
}
