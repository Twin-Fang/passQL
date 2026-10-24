package com.passql.meta.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.PromptChangeType;
import com.passql.meta.dto.PromptHistoryItem;
import com.passql.meta.dto.PromptTemplateSaveRequest;
import com.passql.meta.dto.PromptTestHistoryItem;
import com.passql.meta.dto.PromptVersionItem;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.entity.PromptTemplateHistory;
import com.passql.meta.entity.PromptTestHistory;
import com.passql.meta.repository.PromptTemplateHistoryRepository;
import com.passql.meta.repository.PromptTemplateRepository;
import com.passql.meta.repository.PromptTestHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PromptService {
    // 변경 이력·테스트 이력 조회 최대 건수
    private static final int MAX_HISTORY_COUNT = 50;
    // 테스트 실패 사유 최대 길이 (prompt_test_history.error_message VARCHAR(500))
    private static final int MAX_ERROR_MESSAGE_LENGTH = 500;

    private final PromptTemplateRepository promptTemplateRepository;
    private final PromptTemplateHistoryRepository promptTemplateHistoryRepository;
    private final PromptTestHistoryRepository promptTestHistoryRepository;
    private final ApplicationEventPublisher eventPublisher;

    @Cacheable(value = "prompts", key = "#keyName")
    public PromptTemplate getActivePrompt(String keyName) {
        return promptTemplateRepository.findFirstByKeyNameAndIsActiveTrueOrderByVersionDesc(keyName)
                .orElseThrow(() -> new CustomException(ErrorCode.PROMPT_NOT_FOUND));
    }

    public List<PromptTemplate> findAll() {
        return promptTemplateRepository.findAll(Sort.by(Sort.Direction.ASC, "keyName"));
    }

    public Optional<PromptTemplate> findById(UUID uuid) {
        return promptTemplateRepository.findById(uuid);
    }

    /** 프롬프트 등록 (관리자 폼 요청 > 새 버전 행) */
    @Transactional
    @CacheEvict(value = "prompts", allEntries = true)
    public PromptTemplate create(PromptTemplateSaveRequest request, String adminUsername) {
        PromptTemplate template = PromptTemplate.builder()
                .keyName(request.keyName())
                .version(request.version())
                .isActive(request.isActiveChecked())
                .build();
        applySaveRequest(template, request);
        PromptTemplate saved = promptTemplateRepository.save(template);
        recordHistory(saved, PromptChangeType.CREATE, adminUsername);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.PROMPT, saved.getPromptTemplateUuid(),
                AdminAuditAction.CREATE, null, toPromptAuditSummary(saved)));
        return saved;
    }

    /** 프롬프트 수정 (관리자 폼 요청 > 기존 행 덮어쓰기) */
    @Transactional
    @CacheEvict(value = "prompts", allEntries = true)
    public PromptTemplate update(UUID uuid, PromptTemplateSaveRequest request, String adminUsername) {
        PromptTemplate existing = promptTemplateRepository.findById(uuid)
                .orElseThrow(() -> new CustomException(ErrorCode.PROMPT_NOT_FOUND));
        Map<String, Object> before = toPromptAuditSummary(existing);
        existing.setKeyName(request.keyName());
        existing.setVersion(request.version());
        existing.setIsActive(request.isActiveChecked());
        applySaveRequest(existing, request);
        PromptTemplate saved = promptTemplateRepository.save(existing);
        recordHistory(saved, PromptChangeType.UPDATE, adminUsername);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.PROMPT, uuid, AdminAuditAction.UPDATE,
                before, toPromptAuditSummary(saved)));
        return saved;
    }

    /** 감사 기록용 프롬프트 요약 (본문은 앞부분만) */
    private Map<String, Object> toPromptAuditSummary(PromptTemplate template) {
        return AdminAuditEvent.summary("keyName", template.getKeyName(), "version", template.getVersion(),
                "isActive", template.getIsActive(), "model", template.getModel(),
                "temperature", template.getTemperature(), "maxTokens", template.getMaxTokens(),
                "systemPrompt", template.getSystemPrompt(), "userTemplate", template.getUserTemplate());
    }

    /** 폼 요청 > 모델·프롬프트 본문·생성 파라미터 반영 */
    private void applySaveRequest(PromptTemplate template, PromptTemplateSaveRequest request) {
        template.setModel(request.model());
        template.setSystemPrompt(request.systemPrompt());
        template.setUserTemplate(request.userTemplate());
        template.setTemperature(request.temperature());
        template.setMaxTokens(request.maxTokens());
    }

    public List<PromptTemplate> listVersionsByKeyName(String keyName) {
        return promptTemplateRepository.findByKeyNameOrderByVersionDesc(keyName);
    }

    @Transactional
    @CacheEvict(value = "prompts", allEntries = true)
    public void activateVersion(UUID promptTemplateUuid, String adminUsername) {
        PromptTemplate target = promptTemplateRepository.findById(promptTemplateUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.PROMPT_NOT_FOUND));
        // 같은 keyName 의 다른 버전 비활성화
        List<PromptTemplate> siblings = promptTemplateRepository
                .findByKeyNameOrderByVersionDesc(target.getKeyName());
        for (PromptTemplate sibling : siblings) {
            sibling.setIsActive(sibling.getPromptTemplateUuid().equals(promptTemplateUuid));
            promptTemplateRepository.save(sibling);
        }
        recordHistory(target, PromptChangeType.ACTIVATE, adminUsername);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.PROMPT, promptTemplateUuid, AdminAuditAction.ACTIVATE,
                null, AdminAuditEvent.summary("keyName", target.getKeyName(), "version", target.getVersion())));
    }

    /** 프롬프트 삭제 (활성 버전은 거부, 삭제 직전 상태는 이력에 보관) */
    @Transactional
    @CacheEvict(value = "prompts", allEntries = true)
    public void delete(UUID promptTemplateUuid, String adminUsername) {
        PromptTemplate target = promptTemplateRepository.findById(promptTemplateUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.PROMPT_NOT_FOUND));
        if (Boolean.TRUE.equals(target.getIsActive())) {
            throw new CustomException(ErrorCode.PROMPT_ACTIVE_DELETE_FORBIDDEN);
        }
        recordHistory(target, PromptChangeType.DELETE, adminUsername);
        promptTemplateRepository.delete(target);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.PROMPT, promptTemplateUuid, AdminAuditAction.DELETE,
                toPromptAuditSummary(target), null));
    }

    /** 변경 이력 시점의 본문·파라미터로 되돌림 (keyName·버전·활성 여부는 유지, 되돌림도 새 이력으로 남김) */
    @Transactional
    @CacheEvict(value = "prompts", allEntries = true)
    public PromptTemplate restoreFromHistory(UUID promptTemplateHistoryUuid, String adminUsername) {
        PromptTemplateHistory history = promptTemplateHistoryRepository.findById(promptTemplateHistoryUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.PROMPT_HISTORY_NOT_FOUND));
        PromptTemplate template = promptTemplateRepository.findById(history.getPromptTemplateUuid())
                .orElseThrow(() -> new CustomException(ErrorCode.PROMPT_NOT_FOUND));
        Map<String, Object> before = toPromptAuditSummary(template);
        template.setModel(history.getModel());
        template.setSystemPrompt(history.getSystemPrompt());
        template.setUserTemplate(history.getUserTemplate());
        template.setTemperature(history.getTemperature());
        template.setMaxTokens(history.getMaxTokens());
        PromptTemplate saved = promptTemplateRepository.save(template);
        recordHistory(saved, PromptChangeType.RESTORE, adminUsername);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.PROMPT, saved.getPromptTemplateUuid(),
                AdminAuditAction.RESTORE, before, toPromptAuditSummary(saved)));
        return saved;
    }

    /** 프롬프트 변경 이력 (최신순, 최대 50건) */
    public List<PromptHistoryItem> listHistory(UUID promptTemplateUuid) {
        return promptTemplateHistoryRepository
                .findByPromptTemplateUuidOrderByCreatedAtDesc(promptTemplateUuid, PageRequest.of(0, MAX_HISTORY_COUNT))
                .stream().map(PromptHistoryItem::from).toList();
    }

    /** 같은 keyName 의 전체 버전 (버전 내림차순, diff·롤백 화면용) */
    public List<PromptVersionItem> listVersionItems(UUID promptTemplateUuid) {
        PromptTemplate template = promptTemplateRepository.findById(promptTemplateUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.PROMPT_NOT_FOUND));
        return promptTemplateRepository.findByKeyNameOrderByVersionDesc(template.getKeyName())
                .stream().map(PromptVersionItem::from).toList();
    }

    /** 프롬프트 테스트 결과 1건 기록 (성공·실패 공통, 실패 사유는 500자로 자름) */
    @Transactional
    public void recordTestResult(UUID promptTemplateUuid, String variablesJson, String resultText,
                                 Integer elapsedMilliseconds, boolean isSuccess, String errorMessage,
                                 String adminUsername) {
        String trimmedErrorMessage = errorMessage != null && errorMessage.length() > MAX_ERROR_MESSAGE_LENGTH
                ? errorMessage.substring(0, MAX_ERROR_MESSAGE_LENGTH)
                : errorMessage;
        promptTestHistoryRepository.save(PromptTestHistory.builder()
                .promptTemplateUuid(promptTemplateUuid)
                .variablesJson(variablesJson)
                .resultText(resultText)
                .elapsedMilliseconds(elapsedMilliseconds)
                .isSuccess(isSuccess)
                .errorMessage(trimmedErrorMessage)
                .testedByAdminUsername(adminUsername)
                .build());
    }

    /** 프롬프트 테스트 결과 이력 (최신순, 최대 50건) */
    public List<PromptTestHistoryItem> listTestHistory(UUID promptTemplateUuid) {
        return promptTestHistoryRepository
                .findByPromptTemplateUuidOrderByCreatedAtDesc(promptTemplateUuid, PageRequest.of(0, MAX_HISTORY_COUNT))
                .stream().map(PromptTestHistoryItem::from).toList();
    }

    /** 변경 직후 상태 > 변경 이력 1건 저장 */
    private void recordHistory(PromptTemplate template, PromptChangeType changeType, String adminUsername) {
        promptTemplateHistoryRepository.save(PromptTemplateHistory.builder()
                .template(template)
                .changeType(changeType)
                .changedByAdminUsername(adminUsername)
                .build());
    }
}
