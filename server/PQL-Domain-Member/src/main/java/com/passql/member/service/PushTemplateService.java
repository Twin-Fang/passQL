package com.passql.member.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.dto.PushTemplateSaveRequest;
import com.passql.member.entity.PushTemplate;
import com.passql.member.repository.PushTemplateRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/** 관리자 푸시 템플릿: 목록, 저장(같은 이름은 덮어쓰기), 삭제 + 감사 로그 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PushTemplateService {

    private final PushTemplateRepository pushTemplateRepository;
    private final ApplicationEventPublisher eventPublisher;

    public List<PushTemplate> findAll() {
        return pushTemplateRepository.findAllByOrderByNameAsc();
    }

    /** 저장: 이동 경로 검증 > 같은 이름이면 덮어쓰기, 없으면 추가 */
    @Transactional
    public PushTemplate save(PushTemplateSaveRequest request) {
        PushLinkTarget linkTarget = PushLinkTarget.fromRequestValue(request.linkTarget());
        UUID linkQuestionUuid = linkTarget.isQuestionUuidRequired() ? parseQuestionUuidOrThrow(request.linkQuestionUuid()) : null;
        String name = request.name().trim();
        PushTemplate template = pushTemplateRepository.findByName(name).orElse(null);
        AdminAuditAction action = template == null ? AdminAuditAction.CREATE : AdminAuditAction.UPDATE;
        if (template == null) {
            template = pushTemplateRepository.save(PushTemplate.of(name, request.title().trim(), request.body().trim(), linkTarget, linkQuestionUuid));
        } else {
            template.update(name, request.title().trim(), request.body().trim(), linkTarget, linkQuestionUuid);
        }
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.NOTIFICATION, template.getPushTemplateUuid(), action, null,
                AdminAuditEvent.summary("templateName", name, "title", template.getTitle())));
        log.info("[push template] saved : name={}, action={}", name, action);
        return template;
    }

    /** 삭제 (없으면 PUSH_TEMPLATE_NOT_FOUND) */
    @Transactional
    public void delete(UUID pushTemplateUuid) {
        PushTemplate template = pushTemplateRepository.findById(pushTemplateUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.PUSH_TEMPLATE_NOT_FOUND));
        pushTemplateRepository.delete(template);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.NOTIFICATION, pushTemplateUuid, AdminAuditAction.DELETE, null,
                AdminAuditEvent.summary("templateName", template.getName())));
        log.info("[push template] deleted : name={}", template.getName());
    }

    private static UUID parseQuestionUuidOrThrow(String linkQuestionUuid) {
        try {
            return UUID.fromString(linkQuestionUuid == null ? "" : linkQuestionUuid.trim());
        } catch (IllegalArgumentException e) {
            throw new CustomException(ErrorCode.PUSH_LINK_QUESTION_REQUIRED);
        }
    }
}
