package com.passql.meta.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.LegalStatus;
import com.passql.meta.constant.LegalType;
import com.passql.meta.dto.LegalResponse;
import com.passql.meta.dto.LegalUpdateRequest;
import com.passql.meta.entity.Legal;
import com.passql.meta.entity.LegalHistory;
import com.passql.meta.repository.LegalHistoryRepository;
import com.passql.meta.repository.LegalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.EnumMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class LegalService {

    private final LegalRepository legalRepository;
    private final LegalHistoryRepository legalHistoryRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** PUBLISHED 상태인 약관만 공개 API에서 반환 */
    public LegalResponse getPublished(LegalType type) {
        Legal legal = legalRepository.findByType(type)
                .orElseThrow(() -> new CustomException(ErrorCode.SETTING_NOT_FOUND));
        if (legal.getStatus() != LegalStatus.PUBLISHED) {
            throw new CustomException(ErrorCode.SETTING_NOT_FOUND);
        }
        return LegalResponse.from(legal);
    }

    public List<LegalResponse> findAll() {
        return legalRepository.findAllByOrderByTypeAsc().stream()
                .map(LegalResponse::from)
                .toList();
    }

    /** 약관 수정: 이전 본문 이력 보관 > 제목·본문 교체 > 감사 기록 (#469) */
    @Transactional
    public void update(LegalType type, LegalUpdateRequest request) {
        Legal legal = legalRepository.findByType(type)
                .orElseThrow(() -> new CustomException(ErrorCode.SETTING_NOT_FOUND));
        legalHistoryRepository.save(LegalHistory.snapshotOf(legal));
        Map<String, Object> before = AdminAuditEvent.summary("title", legal.getTitle(), "contentLength", legal.getContent().length());
        legal.setTitle(request.title());
        legal.setContent(request.content());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.LEGAL, type, AdminAuditAction.UPDATE,
                before, AdminAuditEvent.summary("title", request.title(), "contentLength", request.content().length())));
    }

    @Transactional
    public void updateStatus(LegalType type, LegalStatus status) {
        Legal legal = legalRepository.findByType(type)
                .orElseThrow(() -> new CustomException(ErrorCode.SETTING_NOT_FOUND));
        LegalStatus previousStatus = legal.getStatus();
        legal.setStatus(status);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.LEGAL, type, AdminAuditAction.STATUS_CHANGE,
                AdminAuditEvent.summary("status", previousStatus), AdminAuditEvent.summary("status", status)));
    }

    /** 약관 종류별 이전 본문 이력 (최근 20건) */
    public Map<LegalType, List<LegalHistory>> findRecentHistoriesByType() {
        Map<LegalType, List<LegalHistory>> historiesByType = new EnumMap<>(LegalType.class);
        for (LegalType type : LegalType.values()) {
            historiesByType.put(type, legalHistoryRepository.findTop20ByTypeOrderByArchivedAtDesc(type));
        }
        return historiesByType;
    }
}
