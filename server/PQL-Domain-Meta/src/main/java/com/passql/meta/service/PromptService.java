package com.passql.meta.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.dto.PromptTemplateSaveRequest;
import com.passql.meta.entity.PromptTemplate;
import com.passql.meta.repository.PromptTemplateRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PromptService {
    private final PromptTemplateRepository promptTemplateRepository;

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
    public PromptTemplate create(PromptTemplateSaveRequest request) {
        PromptTemplate template = PromptTemplate.builder()
                .keyName(request.keyName())
                .version(request.version())
                .isActive(request.isActiveChecked())
                .build();
        applySaveRequest(template, request);
        return promptTemplateRepository.save(template);
    }

    /** 프롬프트 수정 (관리자 폼 요청 > 기존 행 덮어쓰기) */
    @Transactional
    @CacheEvict(value = "prompts", allEntries = true)
    public PromptTemplate update(UUID uuid, PromptTemplateSaveRequest request) {
        PromptTemplate existing = promptTemplateRepository.findById(uuid)
                .orElseThrow(() -> new CustomException(ErrorCode.PROMPT_NOT_FOUND));
        existing.setKeyName(request.keyName());
        existing.setVersion(request.version());
        existing.setIsActive(request.isActiveChecked());
        applySaveRequest(existing, request);
        return promptTemplateRepository.save(existing);
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
    public void activateVersion(UUID promptTemplateUuid) {
        PromptTemplate target = promptTemplateRepository.findById(promptTemplateUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.PROMPT_NOT_FOUND));
        // 같은 keyName 의 다른 버전 비활성화
        List<PromptTemplate> siblings = promptTemplateRepository
                .findByKeyNameOrderByVersionDesc(target.getKeyName());
        for (PromptTemplate sibling : siblings) {
            sibling.setIsActive(sibling.getPromptTemplateUuid().equals(promptTemplateUuid));
            promptTemplateRepository.save(sibling);
        }
    }
}
