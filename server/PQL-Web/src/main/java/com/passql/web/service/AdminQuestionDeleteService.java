package com.passql.web.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.entity.Question;
import com.passql.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 관리자 문제 삭제: 비활성화(is_active=false)로 처리, 행은 지우지 않음
 * 회원 제출·실행 로그·신고·데일리 이력 보존, 사용자 노출(목록·추천·데일리 후보·벡터 색인)에서만 제외
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminQuestionDeleteService {

    // 일괄 비활성화 건너뜀 사유
    private static final String SKIP_REASON_NOT_FOUND = "문제 없음";
    private static final String SKIP_REASON_ALREADY_INACTIVE = "이미 비활성화됨";

    private final QuestionRepository questionRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** 문제 1건 비활성화 (이미 비활성이면 그대로) */
    @Transactional
    public void deactivateQuestion(UUID questionUuid) {
        Question question = questionRepository.findById(questionUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));
        question.deactivate();
        publishDeactivated(question);
        log.info("[question deactivate] done : questionUuid={}", questionUuid);
    }

    /**
     * 선택 문제 일괄 비활성화: 한 트랜잭션에서 상태 변경만 (부분 삭제 없음)
     * 없는 문제·이미 비활성 문제는 건너뜀 목록으로 반환
     */
    @Transactional
    public BulkDeactivateResult deactivateQuestions(List<UUID> questionUuids) {
        Map<UUID, Question> questionByUuid = questionRepository.findAllById(questionUuids).stream()
                .collect(Collectors.toMap(Question::getQuestionUuid, Function.identity()));

        int deactivatedCount = 0;
        List<String> skippedReasons = new ArrayList<>();
        for (UUID questionUuid : questionUuids) {
            Question question = questionByUuid.get(questionUuid);
            if (question == null) {
                skippedReasons.add(questionUuid + ": " + SKIP_REASON_NOT_FOUND);
                continue;
            }
            if (!Boolean.TRUE.equals(question.getIsActive())) {
                skippedReasons.add(questionUuid + ": " + SKIP_REASON_ALREADY_INACTIVE);
                continue;
            }
            question.deactivate();
            publishDeactivated(question);
            deactivatedCount++;
        }

        log.info("[question deactivate] bulk done : total={}, deactivated={}, skipped={}",
                questionUuids.size(), deactivatedCount, skippedReasons.size());
        return new BulkDeactivateResult(deactivatedCount, skippedReasons.size(), skippedReasons);
    }

    private void publishDeactivated(Question question) {
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.QUESTION, question.getQuestionUuid(),
                AdminAuditAction.DEACTIVATE, AdminAuditEvent.summary("isActive", true), AdminAuditEvent.summary("isActive", false)));
    }

    /** 일괄 비활성화 결과 (deactivated: 처리 건수, skipped: 건너뜀 건수, errors: 건너뜀 사유) */
    public record BulkDeactivateResult(int deactivated, int skipped, List<String> errors) {}
}
