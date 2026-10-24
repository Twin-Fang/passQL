package com.passql.question.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.RequestEnumParser;
import com.passql.question.constant.ChoiceSetSource;
import com.passql.question.constant.ChoiceSetStatus;
import com.passql.question.dto.AdminChoiceSetBulkResult;
import com.passql.question.dto.AdminChoiceSetSearchCondition;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.repository.QuestionChoiceSetItemRepository;
import com.passql.question.repository.QuestionChoiceSetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 관리자 선택지 세트: 이력 조회(출처·상태·문제 필터), 항목 조회, 비활성화, 재사용 풀 승격, 일괄 비활성화·승격
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminChoiceSetService {

    // 일괄 처리 건너뜀 사유
    private static final String SKIP_REASON_NOT_FOUND = "세트 없음";
    private static final String SKIP_REASON_ALREADY_DISABLED = "이미 비활성";
    private static final String SKIP_REASON_NOT_OK = "상태가 OK 가 아님";
    private static final String SKIP_REASON_ALREADY_PROMOTED = "이미 승격됨";

    private final QuestionChoiceSetRepository choiceSetRepository;
    private final QuestionChoiceSetItemRepository choiceSetItemRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** 세트 목록: 출처·상태·문제 uuid 필터 (없는 조건은 무시) */
    public Page<QuestionChoiceSet> getChoiceSets(AdminChoiceSetSearchCondition condition, Pageable pageable) {
        Specification<QuestionChoiceSet> specification = (root, query, builder) -> builder.conjunction();
        if (condition.getSource() != null && !condition.getSource().isBlank()) {
            ChoiceSetSource source = RequestEnumParser.parse(ChoiceSetSource.class, condition.getSource());
            specification = specification.and((root, query, builder) -> builder.equal(root.get("source"), source));
        }
        if (condition.getStatus() != null && !condition.getStatus().isBlank()) {
            ChoiceSetStatus status = RequestEnumParser.parse(ChoiceSetStatus.class, condition.getStatus());
            specification = specification.and((root, query, builder) -> builder.equal(root.get("status"), status));
        }
        if (condition.getQuestionUuid() != null) {
            UUID questionUuid = condition.getQuestionUuid();
            specification = specification.and((root, query, builder) -> builder.equal(root.get("questionUuid"), questionUuid));
        }
        return choiceSetRepository.findAll(specification, pageable);
    }

    public QuestionChoiceSet getChoiceSet(UUID choiceSetUuid) {
        return choiceSetRepository.findById(choiceSetUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.CHOICE_SET_NOT_FOUND));
    }

    public List<QuestionChoiceSetItem> getChoiceSetItems(UUID choiceSetUuid) {
        return choiceSetItemRepository.findByChoiceSetUuidOrderBySortOrderAsc(choiceSetUuid);
    }

    @Transactional
    public void disableChoiceSet(UUID choiceSetUuid) {
        QuestionChoiceSet choiceSet = getChoiceSet(choiceSetUuid);
        disable(choiceSet);
    }

    /** 관리자 큐레이션 출처로 바꾸고 재사용 가능 표시 */
    @Transactional
    public void promoteChoiceSetToReusable(UUID choiceSetUuid) {
        QuestionChoiceSet choiceSet = getChoiceSet(choiceSetUuid);
        promote(choiceSet);
    }

    /** 선택 세트 일괄 비활성화: 없는 세트·이미 비활성은 건너뜀 */
    @Transactional
    public AdminChoiceSetBulkResult disableChoiceSets(List<UUID> choiceSetUuids) {
        Map<UUID, QuestionChoiceSet> choiceSetByUuid = findChoiceSetByUuid(choiceSetUuids);
        int updatedCount = 0;
        List<String> skippedReasons = new ArrayList<>();
        for (UUID choiceSetUuid : choiceSetUuids) {
            QuestionChoiceSet choiceSet = choiceSetByUuid.get(choiceSetUuid);
            if (choiceSet == null) {
                skippedReasons.add(choiceSetUuid + ": " + SKIP_REASON_NOT_FOUND);
            } else if (choiceSet.getStatus() == ChoiceSetStatus.DISABLED) {
                skippedReasons.add(choiceSetUuid + ": " + SKIP_REASON_ALREADY_DISABLED);
            } else {
                disable(choiceSet);
                updatedCount++;
            }
        }
        return new AdminChoiceSetBulkResult(updatedCount, skippedReasons.size(), skippedReasons);
    }

    /** 선택 세트 일괄 재사용 풀 승격: 상태 OK 인 세트만 (실패·비활성 세트는 풀에 넣지 않음), 이미 승격된 세트는 건너뜀 */
    @Transactional
    public AdminChoiceSetBulkResult promoteChoiceSets(List<UUID> choiceSetUuids) {
        Map<UUID, QuestionChoiceSet> choiceSetByUuid = findChoiceSetByUuid(choiceSetUuids);
        int updatedCount = 0;
        List<String> skippedReasons = new ArrayList<>();
        for (UUID choiceSetUuid : choiceSetUuids) {
            QuestionChoiceSet choiceSet = choiceSetByUuid.get(choiceSetUuid);
            if (choiceSet == null) {
                skippedReasons.add(choiceSetUuid + ": " + SKIP_REASON_NOT_FOUND);
            } else if (choiceSet.getStatus() != ChoiceSetStatus.OK) {
                skippedReasons.add(choiceSetUuid + ": " + SKIP_REASON_NOT_OK);
            } else if (choiceSet.getSource() == ChoiceSetSource.ADMIN_CURATED && Boolean.TRUE.equals(choiceSet.getIsReusable())) {
                skippedReasons.add(choiceSetUuid + ": " + SKIP_REASON_ALREADY_PROMOTED);
            } else {
                promote(choiceSet);
                updatedCount++;
            }
        }
        return new AdminChoiceSetBulkResult(updatedCount, skippedReasons.size(), skippedReasons);
    }

    private Map<UUID, QuestionChoiceSet> findChoiceSetByUuid(List<UUID> choiceSetUuids) {
        return choiceSetRepository.findAllById(choiceSetUuids).stream()
                .collect(Collectors.toMap(QuestionChoiceSet::getChoiceSetUuid, Function.identity()));
    }

    private void disable(QuestionChoiceSet choiceSet) {
        ChoiceSetStatus previousStatus = choiceSet.getStatus();
        choiceSet.setStatus(ChoiceSetStatus.DISABLED);
        choiceSetRepository.save(choiceSet);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.CHOICE_SET, choiceSet.getChoiceSetUuid(), AdminAuditAction.DEACTIVATE,
                AdminAuditEvent.summary("status", previousStatus), AdminAuditEvent.summary("status", ChoiceSetStatus.DISABLED)));
    }

    private void promote(QuestionChoiceSet choiceSet) {
        Map<String, Object> before = AdminAuditEvent.summary("source", choiceSet.getSource(), "isReusable", choiceSet.getIsReusable());
        choiceSet.setSource(ChoiceSetSource.ADMIN_CURATED);
        choiceSet.setIsReusable(true);
        choiceSetRepository.save(choiceSet);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.CHOICE_SET, choiceSet.getChoiceSetUuid(), AdminAuditAction.UPDATE,
                before, AdminAuditEvent.summary("source", ChoiceSetSource.ADMIN_CURATED, "isReusable", true)));
    }
}
